from app.core.config import get_app_settings
from celery import Celery

celery_app = Celery(
    "worker",
    broker=get_app_settings().get_rabbitmq_dsn,
    backend=get_app_settings().get_redis_dsn,
)

celery_app.conf.task_routes = {"app.worker.*": "main-queue"}
