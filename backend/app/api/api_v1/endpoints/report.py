from typing import Any

from fastapi import Depends, APIRouter
from fastapi.responses import FileResponse

from backend.app import models
from backend.app.api import deps
from backend.app.core.config import ROOT_PATH

router = APIRouter()


@router.get("/report/{filename}", response_class=FileResponse)
async def read_report(
        filename: str,
        current_user: models.User = Depends(deps.get_current_active_superuser),  # noqa
) -> Any:
    """
    Generate report by user id.\n
    """
    return FileResponse(
        f"{ROOT_PATH}/volumes/postgres/tmp/{filename}",
        filename=filename,
    )
