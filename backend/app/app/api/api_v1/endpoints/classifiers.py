from typing import Any

from fastapi import APIRouter, Depends, HTTPException
from fastapi.params import Query
from starlette.responses import Response

from app import models
from app.api.deps import auth
from app.models import classifiers

router = APIRouter()


# noinspection PyUnusedLocal
@router.get("/")
async def read_classifiers_keys(
    response: Response,
    current_user: models.User = Depends(auth.get_current_active_user),
) -> Any:
    result = [
        {"id": k, "name": v} for k, v in enumerate(list(classifiers.instances.keys()))
    ]
    return result


# noinspection PyUnusedLocal
@router.get("/{name}")
async def read_classifiers(
    response: Response,
    current_user: models.User = Depends(auth.get_current_active_user),
    name: str = Query(None),
) -> Any:
    try:
        assert classifiers.instances.get(name)
    except AssertionError:
        raise HTTPException(400, "Incorrect classifier name")
    result = [
        {"id": k, "name": v} for k, v in enumerate(classifiers.instances.get(name))
    ]
    if not len(result) > 0:
        raise HTTPException(404, "classifiers not exist")
    response.headers["Content-Range"] = f"{0}-{0 + len(result)}/{len(result)}"
    return result
