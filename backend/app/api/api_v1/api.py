from fastapi import APIRouter

from backend.app.api.api_v1.endpoints import login, users

api_router = APIRouter()
api_router.include_router(login.router, prefix="/auth/jwt", tags=["login"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
