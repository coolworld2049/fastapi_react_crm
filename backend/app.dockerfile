FROM python:3.11

COPY app/requirements.txt /app/requirements.txt

RUN pip install --no-cache-dir -r /app/requirements.txt

COPY ./app /app

WORKDIR /app

ENV PYTHONPATH=/app

EXPOSE ${PORT}


