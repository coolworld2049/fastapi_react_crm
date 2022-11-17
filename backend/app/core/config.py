import pathlib

from pydantic import AnyHttpUrl, BaseSettings, EmailStr, validator, PostgresDsn
from typing import List, Optional, Union

# Project Directories
ROOT = pathlib.Path(__file__).resolve().parent.parent


class Settings(BaseSettings):
    API_V1_STR: str = "/api/v1"
    SECRET_KEY: str = "TEST_SECRET_DO_NOT_USE_IN_PROD"
    ALGORITHM: str = "HS256"

    # 60 minutes * 24 hours * 8 days = 8 days
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 8

    # BACKEND_CORS_ORIGINS is a JSON-formatted list of origins
    # e.g: '["http://localhost", "http://localhost:4200", "http://localhost:3000", \
    # "http://localhost:8080", "http://local.dockertoolbox.tiangolo.com"]'
    BACKEND_CORS_ORIGINS: List[AnyHttpUrl] = [
        "http://localhost:3000",
        "http://localhost:8001",  # type: ignore
    ]

    # Origins that match this regex OR are in the above list are allowed
    BACKEND_CORS_ORIGIN_REGEX: Optional[
        str
    ] = "https.*\.(netlify.app|herokuapp.com)"  # noqa: W605

    # noinspection PyMethodParameters
    @validator("BACKEND_CORS_ORIGINS", pre=True)
    def assemble_cors_origins(cls, v: Union[str, List[str]]) -> Union[List[str], str]:  # noqa
        if isinstance(v, str) and not v.startswith("["):
            return [i.strip() for i in v.split(",")]
        elif isinstance(v, (list, str)):
            return v
        raise ValueError(v)

    SYNC_DATABASE_URI: Optional[PostgresDsn] = "postgresql://postgres:postgres@localhost:5432/client_management"
    ASYNC_DATABASE_URL: Optional[
        PostgresDsn] = "postgresql+asyncpg://postgres:postgres@localhost:5432/client_management"
    FIRST_SUPERUSER_USERNAME: EmailStr = "admin@gmail.com"
    FIRST_SUPERUSER_PASSWORD: str = "admin"

    class Config:
        case_sensitive = True

    USERS_OPEN_REGISTRATION = True


settings = Settings()
