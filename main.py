from openai import OpenAI
from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse, FileResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from io import BytesIO
import os

# Your existing utility functions
from utils import extract_pdf
from utils import align_text, align_image
from utils import count_tokens
from utils import split_transcript
from utils import get_summary
from utils import add_text_to_pdf_and_save


app = FastAPI()

# Set up CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)
with open("openai_key.txt", "r") as file:
    api_key = file.read()

client = OpenAI(api_key=api_key)

@app.get("/")
async def read_root():
    return {"Hello": "World"}

@app.post("/process-audio/")
def process_audio(audio: UploadFile = File(...)):
    try:
        # Save the uploaded audio file to a directory (e.g., './uploaded_files/')
        file_location = f"./uploaded_files/{audio.filename}"
        with open(file_location, "wb+") as file_object:
            file_object.write(audio.file.read())

        audio_file = open(file_location, "rb")
        
        # Transcripting the audio
        transcript = client.audio.transcriptions.create(
            model="whisper-1", 
            file=audio_file,
            language="en"
        )
    
        # Summarizing the transcription
        summary_response = summarize(transcript.text)
        return {"summary": summary_response['summary']}
    except Exception as e:
        return JSONResponse(status_code=400, content={"message": f"An error occurred: {e}"})
    
    finally:
        os.remove(file_location)

@app.post("/summarize")
def summarize(text: str):
    MODEL = "gpt-3.5-turbo"
    try:
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
        return {"summary": summary}
    except Exception as e:
        return JSONResponse(status_code=400, content={"message": f"An error occurred: {e}"})


@app.post("/align-slides")
async def align(audio: UploadFile = File(...), slides: UploadFile = File(...)):
    audio_file_location = f"./uploaded_files/{audio.filename}"
    slides_file_location = f"./uploaded_files/{slides.filename}"

    try:
        with open(audio_file_location, "wb+") as audio_file_object:
            # Use await with async read()
            file_data = await audio.read()
            audio_file_object.write(file_data)

        # Process the audio file to get the transcript
        with open(audio_file_location, "rb") as audio_file:
            transcript_response = client.audio.transcriptions.create(
                model="whisper-1", 
                file=audio_file,
                language="en"
            )
        transcript = transcript_response.text

        # Save the uploaded slides file
        with open(slides_file_location, "wb") as slides_file_object:
            slides_data = await slides.read()
            slides_file_object.write(slides_data)

        # Extract data from the slides and align them with the transcript
        data = extract_pdf(slides_file_location)
        transcript_list = split_transcript(transcript, n_chunks=len(data))

        response = []
        for i, (content_dict, slide_transcript) in enumerate(zip(data, transcript_list)):
            previous_info = "\n".join([d['content'] for d in response[-3:]])

            if content_dict["type"] == "text":
                alignment = align_text(slide_transcript, transcript, previous_info, content_dict["content"], client=client)
            elif content_dict["type"] == "image":
                alignment = align_image(slide_transcript, transcript, previous_info, content_dict["content"], api_key=api_key)

            response.append({"slide_number": i + 1, "content": alignment})

        output_file = f"./uploaded_files/aligned_{slides.filename}"
        add_text_to_pdf_and_save(slides_file_location, output_file, response)

        return FileResponse(output_file, media_type="application/pdf", headers={"Content-Disposition": f"attachment; filename=aligned_{slides.filename}"})

    except Exception as e:
        # Log the exception for debugging
        print(f"An error occurred: {e}")
        return JSONResponse(status_code=400, content={"message": f"An error occurred: {e}"})

    finally:
        # Clean up the uploaded files
        if os.path.exists(audio_file_location):
            os.remove(audio_file_location)
        if os.path.exists(slides_file_location):
            os.remove(slides_file_location)