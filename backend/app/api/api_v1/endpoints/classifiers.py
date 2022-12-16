from typing import Any, Dict, List

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

    if name == 'students':
        result = [{k: [{'id': k2, 'name': k2} for k2 in v if str(k2).split('_')[0] == 'student']}
                  for k, v in classifiers.instances.items() if k == 'user_role']
    elif name == 'teachers':
        result = [{k: [{'id': k2, 'name': k2} for k2 in v if str(k2).split('_')[0] == 'teacher']}
                  for k, v in classifiers.instances.items() if k == 'user_role']
    elif name == 'all':
        result = [{k: [{'id': k2, 'name': k2} for k2 in v]} for k, v in classifiers.instances.items()]
    else:
        result = [{'id': k, 'name': v} for k, v in classifiers.instances.get(name).items()]
    if not result:
        raise HTTPException(404, 'classifiers not exist')
    response.headers["Content-Range"] = f"{0}-{0 + len(result)}/{len(result)}"
    return result
