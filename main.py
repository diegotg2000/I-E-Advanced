from openai import OpenAI
from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse
from io import BytesIO
import os

app = FastAPI()

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

        transcript = client.audio.transcriptions.create(
            model="whisper-1", 
            file=audio_file,
            language="en"
        )

        return {"filename": audio.filename, "transcript": transcript.text}
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