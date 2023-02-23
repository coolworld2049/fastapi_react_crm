FROM python:3.11

COPY app/requirements.txt /app/requirements.txt

RUN pip install --no-cache-dir -r /app/requirements.txt

COPY ./app /app

WORKDIR /app

ENV PYTHONPATH=/app

ENV C_FORCE_ROOT=1

COPY app/worker-start.sh /worker-start.sh

RUN chmod +x /worker-start.sh

CMD ["bash", "/worker-start.sh"]
