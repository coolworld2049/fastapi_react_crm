import logging
import sys
from logging.handlers import RotatingFileHandler
from typing import Any, Optional

from loguru import logger
from pydantic import EmailStr

from app.core.logging import InterceptHandler
from app.core.settings.base import BaseAppSettings


class AppSettings(BaseAppSettings):
    docs_url: str = "/docs"
    api_v1: str = "/api/v1"
    openapi_prefix: str = ""
    openapi_url: str = f"{api_v1}/openapi.json"
    redoc_url: str = "/redoc"
    title: str = "fastapi_admin"
    version: str = "0.0.0"

    APP_NAME: str
    TZ: str
    DEBUG: bool

    DOMAIN: str
    PORT: int

    BACKEND_CORS_ORIGINS: list[str]
    JWT_ALGORITHM: str
    JWT_SECRET_KEY: str
    JWT_PRIVATE_KEY: Optional[str]  # ?
    JWT_PUBLIC_KEY: Optional[str]  # ?
    ACCESS_TOKEN_EXPIRE_MINUTES: int
    FIRST_SUPERUSER_USERNAME: str
    FIRST_SUPERUSER_EMAIL: EmailStr | str
    FIRST_SUPERUSER_PASSWORD: str

    PG_HOST: str
    PG_PORT: int
    POSTGRES_DB: str
    POSTGRES_USER: str
    POSTGRES_PASSWORD: str
    PG_DRIVER: str = "asyncpg"

    RABBITMQ_HOST: str
    RABBITMQ_PORT: int
    RABBITMQ_HTTP_PORT: int
    RABBITMQ_DEFAULT_USER: str
    RABBITMQ_DEFAULT_PASS: str

    REDIS_HOST: str
    REDIS_PORT: int

    LOGGING_LEVEL: str = "INFO"
    LOGGERS: tuple[str, str] = ("uvicorn.asgi", "uvicorn.access")
    LOG_FILE_MAX_BYTES = 314572800

    class Config:
        validate_assignment = True

    @property
    def get_fastapi_kwargs(self) -> dict[str, Any]:
        return {
            "debug": self.DEBUG,
            "docs_url": self.docs_url,
            "openapi_prefix": self.openapi_prefix,
            "openapi_url": self.openapi_url,
            "redoc_url": self.redoc_url,
            "title": self.title,
            "version": self.version,
        }

    @property
    def get_raw_postgres_dsn(self):
        return f"postgresql://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}@{self.PG_HOST}:{self.PG_PORT}/{self.POSTGRES_DB}"

    @property
    def get_postgres_asyncpg_dsn(self):
        return f"postgresql+asyncpg://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}@{self.PG_HOST}:{self.PG_PORT}/{self.POSTGRES_DB}"

    @property
    def get_test_postgres_asyncpg_dsn(self):
        return f"postgresql+asyncpg://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}@{self.PG_HOST}:{self.PG_PORT}/test"

    @property
    def get_rabbitmq_dsn(self):
        return f"pyamqp://{self.RABBITMQ_DEFAULT_USER}:{self.RABBITMQ_DEFAULT_PASS}@{self.RABBITMQ_HOST}:{self.RABBITMQ_PORT}/"

    @property
    def get_redis_dsn(self):
        return f"redis://{self.REDIS_HOST}:{self.REDIS_PORT}/"

    def configure_logging(self) -> None:
        logging.getLogger().handlers = [InterceptHandler()]
        for logger_name in self.LOGGERS:
            logging_logger = logging.getLogger(logger_name)
            logging_logger.handlers = [
                InterceptHandler(level=self.LOGGING_LEVEL),
                RotatingFileHandler(
                    "access.log",
                    maxBytes=self.LOG_FILE_MAX_BYTES,
                    backupCount=1,
                ),
            ]

        logger.configure(handlers=[{"sink": sys.stdout, "level": self.LOGGING_LEVEL}])
