# syntax=docker/dockerfile:1
FROM tiangolo/uvicorn-gunicorn-fastapi:python3.7
WORKDIR /code
COPY requirements.txt requirements.txt
COPY openai_key.txt openai_key.txt
RUN pip install -r requirements.txt
EXPOSE 5000
COPY ./main.py /code/
COPY ./utils.py /code/
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "5000"]