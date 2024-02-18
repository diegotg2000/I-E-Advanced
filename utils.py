import base64
import io
import textwrap

import fitz
import requests
import tiktoken
from openai import OpenAI
from PIL import Image, ImageDraw, ImageFont

encoding = tiktoken.encoding_for_model('gpt-4')

SYSTEM_PROMPT = {}

with open("gpt3_5-prompt.txt", "r") as file:
    SYSTEM_PROMPT['gpt-3.5-turbo'] = file.read()

with open("gpt4-prompt.txt", "r") as file:
    SYSTEM_PROMPT['gpt-4-vision-preview'] = file.read()


#### FUNCTIONS TO ALIGN CONTENT
    
def get_summary(text: str, *, client: OpenAI):
    MODEL = "gpt-3.5-turbo"
    response = client.chat.completions.create(
        model=MODEL,
        messages=[
            {
                "role": "system", 
                "content": "You are a helpful assistant. Your role is to summarize the transcription of a lecture. Do not say hello or anything, just provide the answer."},
            {
                "role": "user", 
                "content": text
            }
        ],
        temperature=0,
    )
    summary = response.choices[0].message.content
    return summary

def align_text(transcript: str, summary: str, previous_info: str, text: str, *, client: OpenAI):
    MODEL = "gpt-3.5-turbo"
    system_prompt = SYSTEM_PROMPT[MODEL]

    data_str = f"Slides Content:\n{text}\nLecture Summary:\n{summary}\nInformation previously added to slides:\n{previous_info}\nTranscription:\n{transcript}"

    print(data_str)

    response = client.chat.completions.create(
        model=MODEL,
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": data_str},
        ],
        temperature=0,
    )

    return response.choices[0].message.content


def align_image(transcript: str, summary: str, previous_info: str, image: str, *, api_key: str):
    MODEL = "gpt-4-vision-preview"
    system_prompt = SYSTEM_PROMPT[MODEL]

    headers = {"Content-Type": "application/json", "Authorization": f"Bearer {api_key}"}

    data_str = f"Lecture summary:\n{summary}\nInformation previously added to the slides:\n{previous_info}\nTranscription: {transcript}"

    print(data_str)

    payload = {
        "model": MODEL,
        "messages": [
            {
                "role": "system",
                "content": system_prompt,
            },
            {
                "role": "user",
                "content": [
                    {
                        "type": "image_url",
                        "image_url": {"url": f"data:image/jpeg;base64,{image}"},
                    },
                    {"type": "text", "text": data_str},
                ],
            },
        ],
        "max_tokens": 300,
    }

    response = requests.post(
        "https://api.openai.com/v1/chat/completions", headers=headers, json=payload
    )
    return response.json()["choices"][0]["message"]["content"]


### PDF EXTRACTION FUNCTIONS

def page2bytes(page: fitz.Page):
    """Convert a page to a bytes object"""
    stream = page.get_pixmap(dpi=25)
    return base64.b64encode(stream.tobytes()).decode("utf-8")


def extract_pdf(file_location: str):
    slides_file = fitz.open(file_location)

    pages = []
    for page in slides_file:
        text = page.get_text("text")
        if len(text) > 20:
            if count_tokens(text) < 500:
                pages.append({"type": "text", "content": text})
            else:
                pages.append({"type": "image", "content": page2bytes(page)})

        else:
            pages.append({"type": "image", "content": page2bytes(page)})

    return pages


### PDF EDITING FUNCTIONS

def add_text_to_pdf_and_save(pdf_path, output_pdf_path, text_list, font_size=12):
    doc = fitz.open(pdf_path)
    new_images = []

    for page, text_data in zip(doc, text_list):
        img = process_page_and_add_text(page, text_data['content'], font_size)
        new_images.append(img)
    
    # Save the first image as PDF and append the rest
    new_images[0].save(output_pdf_path, "PDF", resolution=100.0, save_all=True, append_images=new_images[1:])


def process_page_and_add_text(page, text, font_size=12, max_width=None):
    # Convert fitz.Page to fitz.Pixmap, then to PIL Image
    pix = page.get_pixmap() 
    img_bytes = pix.tobytes("png")  # Get PNG bytes
    img = Image.open(io.BytesIO(img_bytes))

    if len(text) == 0:
        return img
    
    # Expand the image by adding white space to the right
    width, height = img.size
    new_width = width * 1.4  # Adjust the factor as needed
    new_img = Image.new("RGB", (int(new_width), height), "white")
    new_img.paste(img, (0, 0))
    
    # Prepare to add text to the new white space
    draw = ImageDraw.Draw(new_img)
    font = ImageFont.load_default()  # or ImageFont.truetype(font_path, font_size) for custom fonts
    
    # Determine the available width for text
    if max_width is None:
        max_width = new_width - width - 40  # Adjust padding as needed
    
    # Split text into lines
    char_size = draw.textlength(text.replace('\n',''), font=font)/len(text)
    max_char = int(max_width / (char_size * 0.9))  # Adjust the factor as needed
    lines = textwrap.wrap(text, width=max_char)  # Adjust width for your needs or dynamically based on max_width and font size

    # Calculate the starting Y position
    text_y = (height - (len(lines) * font_size)) / 2  # Centered vertically
    
    # Draw each line of text
    for line in lines:
        text_left, text_top, text_right, text_bottom = draw.textbbox((0,0), line, font=font)
        text_width = text_right - text_left
        text_height = text_bottom - text_top
        text_x = width + (new_width - width - text_width) / 2
        draw.text((text_x, text_y), line, fill="black", font=font)
        text_y += text_height  # Move down to draw the next line

    return new_img


### TRANSCRIPT FUNCTIONS

def split_transcript(transcript: str, n_chunks: int):
    # Split the transcript into n_chunks
    tokens = encoding.encode(transcript)

    hop_size = len(tokens) // n_chunks

    chunk_size = min(3*hop_size, 3000)

    chunks = []

    for i in range(n_chunks):
        chunk_center = (i+1/2)*hop_size
        start = max(0, int(chunk_center - chunk_size/2))
        end = min(int(chunk_center + chunk_size/2), len(tokens))
        chunks.append(encoding.decode(tokens[start:end]))
    
    return chunks


### TIKTOKEN FUNCTIONS

def count_tokens(text: str):
    n_tokens = len(encoding.encode(text))
    return n_tokens

