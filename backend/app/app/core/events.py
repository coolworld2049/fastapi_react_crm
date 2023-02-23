from collections.abc import Callable

from fastapi import FastAPI
from loguru import logger

from app.core.config import get_app_settings
from app.core.settings.app import AppSettings
from app.db.init_db import init_db
from app.db.session import engine, SessionLocal


local_logger = logger.opt(colors=True)


# noinspection PyUnusedLocal
def create_start_app_handler(
    app: FastAPI,
    settings: AppSettings,
) -> Callable:
    async def start_app() -> None:
        local_logger.warning("<m>Application startup!</m>")
        if get_app_settings().APP_ENV.name == "dev":
            await init_db()

    return start_app


# noinspection PyUnusedLocal
def create_stop_app_handler(app: FastAPI) -> Callable:
    async def stop_app() -> None:
        SessionLocal.close_all()
        local_logger.warning("all sessionmaker session closed")

        await engine.dispose()
        local_logger.warning("engine disposed")
        local_logger.warning("<y>Application shutdown!</y>")

    return stop_app
