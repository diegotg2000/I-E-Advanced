import base64
import requests
import fitz
from openai import OpenAI
import tiktoken


encoding = tiktoken.encoding_for_model('gpt-4')


#### FUNCTIONS TO ALIGN CONTENT

def align_text(transcript: str, text: str, *, client: OpenAI):
    MODEL = "gpt-3.5-turbo"
    SYSTEM_PROMPT = "You are a helpful assistant. The user will give you the content of a slide, and the transcription of a lecture concerning the slide. Please extract the information of the transcription that is relevant for that slide. Beware of not repeating information that is in the slide, the central goal is to add new information, the slide description is only there so you know what to extract from the transcription. If you think there isn't much to add, simply output an empty string. Otherwise, output a bullet point list and do not add any extra remarks."

    data_str = f"Slides Content:\n{text}\nTranscription:\n{transcript}"

    response = client.chat.completions.create(
        model=MODEL,
        messages=[
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": data_str},
        ],
        temperature=0,
    )

    return response.choices[0].message.content


def align_image(transcript: str, image: str, *, api_key: str):
    MODEL = "gpt-4-vision-preview"
    SYSTEM_PROMPT = "You are a helpful assistant. The user will give you the image of a slide as base64, and the transcription of a lecture concerning the slide. Please extract the information of the transcription that is relevant for that slide. Beware of not repeating information that is in the slide, the central goal is to add new information, the slide description is only there so you know what to extract from the transcription. If you think there isn't much to add, simply output an empty string. Otherwise, output a bullet point list and do not add any extra remarks."

    headers = {"Content-Type": "application/json", "Authorization": f"Bearer {api_key}"}

    payload = {
        "model": MODEL,
        "messages": [
            {
                "role": "system",
                "content": SYSTEM_PROMPT,
            },
            {
                "role": "user",
                "content": [
                    {
                        "type": "image_url",
                        "image_url": {"url": f"data:image/jpeg;base64,{image}"},
                    },
                    {"type": "text", "text": f"Transcription: {transcript}"},
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
            pages.append({"type": "text", "content": text})
        else:
            pages.append({"type": "image", "content": page2bytes(page)})

    return pages


### TRANSCRIPT FUNCTIONS

def split_transcript(transcript: str, n_chunks: int):
    # Split the transcript into n_chunks (overlapping by 50%)
    tokens = encoding.encode(transcript)

    chunk_size = len(tokens) // n_chunks

    chunks = []

    for i in range(n_chunks):
        start = max(0, (i-1)*chunk_size)
        end = min((i+2)*chunk_size, len(tokens))
        chunks.append(encoding.decode(tokens[start:end]))
    
    return chunks


### TIKTOKEN FUNCTIONS

def count_tokens(text: str):
    n_tokens = len(encoding.encode(text))
    return n_tokens

