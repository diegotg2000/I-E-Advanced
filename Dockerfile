# syntax=docker/dockerfile:1
FROM tiangolo/uvicorn-gunicorn-fastapi:python3.8
WORKDIR /code
COPY requirements.txt requirements.txt
COPY openai_key.txt openai_key.txt
RUN pip install --upgrade pip
RUN pip install -r requirements.txt
EXPOSE 5000
COPY ./main.py /code/
COPY ./utils.py /code/
RUN mkdir -p /code/uploaded_files
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "5000"]