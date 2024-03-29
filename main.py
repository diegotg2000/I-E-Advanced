from openai import OpenAI
from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse, FileResponse
from io import BytesIO
import os
from utils import extract_pdf
from utils import align_text, align_image
from utils import count_tokens
from utils import split_transcript
from utils import get_summary
from utils import add_text_to_pdf_and_save

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
    try:
        summary = get_summary(text, client=client)
        return {"summary": summary}
    except Exception as e:
        return JSONResponse(status_code=400, content={"message": f"An error occurred: {e}"})
    

@app.post("/align-slides")
async def align(transcript: str, slides: UploadFile = File(...)):
    try:
        # Save the uploaded slides file to a directory (e.g., './uploaded_files/')
        file_location = f"./uploaded_files/{slides.filename}"
        with open(file_location, "wb") as buffer:
            buffer.write(await slides.read())

        data = extract_pdf(file_location)

        summary = get_summary(transcript, client=client)

        transcript_list = split_transcript(transcript, n_chunks=len(data))

        response = []

        for i, (content_dict, slide_transcript) in enumerate(zip(data, transcript_list)):
            previous_info = "\n".join([d['content'] for d in response[-3:]])

            if content_dict["type"] == "text":
                alignment = align_text(slide_transcript, summary, previous_info, content_dict["content"], client=client)

            elif content_dict["type"] == "image":
                alignment = align_image(slide_transcript, summary, previous_info, content_dict["content"], api_key=api_key)

            response.append({"slide_number": i+1, "content": alignment})

            if len(response) >= 10:
                break

        output_file = f"./uploaded_files/aligned_{slides.filename}"

        add_text_to_pdf_and_save(file_location, output_file, response)

        return FileResponse(output_file, media_type="application/pdf", headers={"Content-Disposition": f"attachment; filename=aligned_{slides.filename}"})
    
    except Exception as e:
        return JSONResponse(status_code=400, content={"message": f"An error occurred: {e}"})
    
    finally:
        os.remove(file_location)