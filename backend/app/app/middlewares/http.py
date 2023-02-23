from loguru import logger
from starlette.requests import Request
from starlette.responses import Response

from app.main import app  # noqa


# @app.middleware("http")
async def catch_exceptions_middleware(request: Request, call_next):
    try:
        return await call_next(request)
    except Exception as e:
        # you probably want some kind of logging here
        logger.exception(e.args)
        return Response("Internal server error", status_code=500)
