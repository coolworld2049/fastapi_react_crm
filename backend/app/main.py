import logging
import pathlib
from pathlib import Path

import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.openapi.utils import get_openapi
from fastapi.routing import APIRoute
from starlette.responses import FileResponse
from starlette.staticfiles import StaticFiles

from backend.app.api.api_v1.api import api_router
from backend.app.core.config import settings, ROOT_PATH
from backend.app.utils.custom_logger import CustomizeLogger

logger = logging.getLogger()


def create_app() -> FastAPI:
    logger_config_path = pathlib.Path(f"{ROOT_PATH}/utils/logging_config.json")

    _app = FastAPI(title="fast-api-react-crm",
                   openapi_url=f"{settings.API_V1_STR}/openapi.json",
                   debug=True, )

    _logger = CustomizeLogger.make_logger(logger_config_path)
    _app.logger = _logger

    return _app


app = create_app()

if settings.BACKEND_CORS_ORIGINS:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=[str(origin) for origin in settings.BACKEND_CORS_ORIGINS],
        allow_origin_regex=settings.BACKEND_CORS_ORIGIN_REGEX,
        allow_credentials=True,
        allow_methods=["*"],
        expose_headers=["Content-Range", "Range"],
        allow_headers=["*", "Authorization", "Range", "Content-Range"],
    )

app.include_router(api_router, prefix=settings.API_V1_STR)

BASE_PATH = Path(__file__).resolve().parent

app.mount("/static", StaticFiles(directory=f"{BASE_PATH}/static", html=True), name="static")
app.mount("/static/users/reports", StaticFiles(directory=f"{BASE_PATH}/volumes/postgres/tmp"),
          name="static/users/reports")


def custom_openapi():
    if app.openapi_schema:
        return app.openapi_schema
    openapi_schema = get_openapi(
        title="fastapi-react-crm-backend",
        version="1.0.0",
        description="OpenAPI schema",
        routes=app.routes,
    )
    openapi_schema["info"]["x-logo"] = {
        "url": "https://fastapi.tiangolo.com/img/logo-margin/logo-teal.png"
    }
    app.openapi_schema = openapi_schema
    return app.openapi_schema


app.openapi = custom_openapi


# noinspection PyShadowingNames
def use_route_names_as_operation_ids(app: FastAPI) -> None:
    """
    Simplify operation IDs so that generated API clients have simpler function
    names.

    Should be called only after all routes have been added.
    """
    route_names = set()
    for route in app.routes:
        if isinstance(route, APIRoute):
            if route.name in route_names:
                raise Exception("Route function names should be unique")
            route.operation_id = route.name
            route_names.add(route.name)


use_route_names_as_operation_ids(app)


@app.get("/")
def root():
    return FileResponse(f'{BASE_PATH}/static/index.html')


if __name__ == '__main__':
    uvicorn.run('backend.app.main:app', port=8000)
