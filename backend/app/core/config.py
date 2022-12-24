import pathlib
from typing import List, Optional, Union

import pytz
from envparse import env
from pydantic import AnyHttpUrl, BaseSettings, validator, PostgresDsn

# Project Directories
ROOT_PATH = pathlib.Path(__file__).resolve().parent.parent


class Settings(BaseSettings):
    debug = True

    APP_NAME = 'fastapi-react-crm-backend'
    APP_VERSION = '0.0.1'
    ENVIRONMENT = f'{pathlib.Path(__file__).resolve().parent.parent}/.env'

    RUN_ON_DOCKER = False

    env.read_envfile(ENVIRONMENT)

    SERVER_TZ = pytz.timezone(env.str('PGTZ', default='Europe/Moscow'))

    API_V1_STR: str = "/api/v1"
    ALGORITHM: str = "HS256"
    SECRET_KEY: str = env.str('JWT_SECRET_KEY')

    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 8

    BACKEND_CORS_ORIGINS: List[AnyHttpUrl] = ["http://localhost:3000", ]

    # Origins that match this regex OR are in the above list are allowed
    BACKEND_CORS_ORIGIN_REGEX: Optional[str] = "https.*\.(netlify.app|herokuapp.com)"

    # noinspection PyMethodParameters
    @validator("BACKEND_CORS_ORIGINS", pre=True)
    def assemble_cors_origins(cls, v: Union[str, List[str]]) -> Union[List[str], str]:  
        if isinstance(v, str) and not v.startswith("["):
            return [i.strip() for i in v.split(",")]
        elif isinstance(v, (list, str)):
            return v
        raise ValueError(v)

    pg_host = f'postgres' if RUN_ON_DOCKER else 'localhost'
    mongo_host = f'mongo' if RUN_ON_DOCKER else 'localhost'

    POSTGRES_URL: Optional[PostgresDsn] = \
        f"postgresql://" \
        f"{env.str('PG_SUPERUSER')}:{env.str('PG_SUPERUSER_PASSWORD')}" \
        f"@{pg_host}:{env.str('PG_PORT')}" \
        f"/{env.str('PG_NAME')}"

    ASYNC_POSTGRES_URL: Optional[PostgresDsn] = \
        f"postgresql+asyncpg://" \
        f"{env.str('PG_SUPERUSER')}:{env.str('PG_SUPERUSER_PASSWORD')}" \
        f"@{pg_host}:{env.str('PG_PORT')}" \
        f"/{env.str('PG_NAME')}"

    FIRST_SUPERUSER_USERNAME: str = env.str('FIRST_SUPERUSER_USERNAME')
    FIRST_SUPERUSER_EMAIL: str = env.str('FIRST_SUPERUSER_EMAIL')
    FIRST_SUPERUSER_PASSWORD: str = env.str('FIRST_SUPERUSER_PASSWORD')

    class Config:
        case_sensitive = True


settings = Settings()
