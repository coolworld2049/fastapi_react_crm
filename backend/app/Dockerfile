FROM tiangolo/uvicorn-gunicorn-fastapi:python3.10
WORKDIR /fastapi-react-crm-backend/backend/app

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV PYTHONPATH=/fastapi-react-crm-backend/backend/app

COPY / .
RUN pip3 install --no-cache-dir -r requirements.txt

WORKDIR /fastapi-react-crm-backend/

CMD uvicorn backend.app.main:app --reload --proxy-headers --host 0.0.0.0

