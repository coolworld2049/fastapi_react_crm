from app.core.config import get_app_settings
from fastapi import FastAPI
from fastapi.openapi.utils import get_openapi
from fastapi.routing import APIRoute


def custom_openapi(app: FastAPI):
    if app.openapi_schema:
        return app.openapi_schema
    openapi_schema = get_openapi(
        title=get_app_settings().title,
        version=get_app_settings().version,
        routes=app.routes,
    )
    openapi_schema["info"]["x-logo"] = {
        "url": "https://fastapi.tiangolo.com/img/logo-margin/logo-teal.png",
    }
    app.openapi_schema = openapi_schema
    return app.openapi_schema


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
