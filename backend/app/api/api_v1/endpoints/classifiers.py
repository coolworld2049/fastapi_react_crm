from typing import Any

from fastapi import APIRouter, Depends, HTTPException
from fastapi.params import Query
from starlette.responses import Response

from backend.app.api import deps
from backend.app.db import models, classifiers

router = APIRouter()


# noinspection PyUnusedLocal
@router.get("/{name}")
async def read_classifiers(
        response: Response,
        current_user: models.User = Depends(deps.get_current_active_user),
        name: str = Query(None)
) -> Any:

    if name == 'all':
        result = [{k: [{'id': k2, 'name': v2} for k2, v2 in v.items()]} for k, v in classifiers.instances.items()]
    else:
        result = [{'id': k, 'name': v} for k, v in classifiers.instances.get(name).items()]
    if not len(result) > 0:
        raise HTTPException(404, 'classifiers not exist')
    response.headers["Content-Range"] = f"{0}-{0 + len(result)}/{len(result)}"
    return result
