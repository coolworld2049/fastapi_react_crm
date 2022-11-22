from fastapi import APIRouter

from backend.app.api.api_v1.endpoints import login, users, tasks

api_router = APIRouter()
api_router.include_router(login.router, tags=["auth"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(tasks.router, prefix="/tasks", tags=["tasks"])
