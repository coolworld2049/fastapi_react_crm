from fastapi import APIRouter

from backend.app.api.api_v1.endpoints import login, users, tasks, report

api_router = APIRouter()
api_router.include_router(login.router, tags=["login"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(tasks.router, prefix="/tasks", tags=["tasks"])
api_router.include_router(report.router, prefix="/report", tags=["report"])

