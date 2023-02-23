from fastapi.security import OAuth2PasswordBearer

from app import crud
from app import schemas
from app.api.deps import database
from app.core.config import get_app_settings
from app.models.domain import User
from asyncpg import Connection
from fastapi import Depends
from fastapi import HTTPException
from loguru import logger
from jose import jwt
from jose import JWTError
from sqlalchemy import text
from sqlalchemy.engine import Result
from sqlalchemy.ext.asyncio import AsyncSession
from starlette import status

oauth2Scheme = OAuth2PasswordBearer(
    tokenUrl=f"{get_app_settings().api_v1}/login/access-token",
)


async def get_current_user(
    db: AsyncSession = Depends(database.get_db),
    token: str = Depends(oauth2Scheme),
) -> User:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(
            token=token,
            key=get_app_settings().JWT_SECRET_KEY,
            algorithms=get_app_settings().JWT_ALGORITHM,
            options={"verify_aud": False},
        )
        subject: str = payload.get("sub")
        if not subject:
            raise credentials_exception
        token_data = schemas.TokenPayload(sub=subject)
    except JWTError:
        raise credentials_exception

    user = await crud.user.get_by_id(db=db, id=int(token_data.sub))
    if user is None:
        raise credentials_exception
    await auth_in_db(db, user)
    return user


async def get_current_active_user(
    current_user: User = Depends(get_current_user),
) -> User:
    if not current_user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user


async def get_current_active_superuser(
    current_user: User = Depends(get_current_user),
) -> User:
    if not current_user.is_superuser:
        raise HTTPException(
            status_code=400,
            detail="The user doesn't have enough privileges",
        )
    return current_user


async def auth_in_db(db: AsyncSession, user: User):
    await get_session_user(db)
    await reset_session_user(db)
    await get_session_user(db)
    if not await is_rolname_exist(db, user):
        await create_user_in_role(db, user)
    await reset_session_user(db)
    await get_session_user(db)
    await set_session_user(db, user)
    await get_session_user(db)


async def is_rolname_exist(db: AsyncSession, current_user: User):
    if not current_user.is_active:
        raise HTTPException(400, "user is not active")
    check_q = """select rolname from pg_roles where rolname = :db_user"""
    check_q_result: Result = await db.execute(
        text(check_q),
        {"db_user": current_user.username.lower()},
    )

    check_result = check_q_result.fetchall()
    if get_app_settings().APP_ENV in ["dev", "test"]:
        logger.info(
            f"{f'{current_user.username} rolname exist' if check_result else f'{current_user.username} rolname not exist'}",
        )
    return check_result


async def create_user_in_role(db: AsyncSession, current_user: User):
    create_db_user_q = (
        """select create_user_in_role(:db_user, :hashed_password, :role)"""
    )
    params = {
        "db_user": current_user.username.lower(),
        "hashed_password": current_user.hashed_password,
        "role": current_user.role,
    }
    await db.execute(text(create_db_user_q), params=params)
    await db.commit()
    if get_app_settings().APP_ENV in ["dev", "test"]:
        logger.info("created")


async def drop_user_in_role(db: AsyncSession | Connection, current_user: User):
    drop_db_user_q = """drop user """ + current_user.username.lower()
    if isinstance(db, Connection):
        await db.execute(drop_db_user_q)
    elif isinstance(db, AsyncSession):
        await db.execute(text(drop_db_user_q))
    if get_app_settings().APP_ENV in ["dev", "test"]:
        logger.info(current_user.username)


async def get_session_user(db: AsyncSession):
    check_session_role_q = """select session_user, current_user"""
    check_session_role_q_result: Result = await db.execute(text(check_session_role_q))
    if get_app_settings().APP_ENV in ["dev", "test"]:
        logger.info(check_session_role_q_result.scalar())


async def set_session_user(db: AsyncSession, current_user: User):
    set_db_user_q = """set session authorization """ + current_user.username.lower()
    if get_app_settings().APP_ENV in ["dev", "test"]:
        logger.info(current_user.username)
    await db.execute(text(set_db_user_q))


async def reset_session_user(db: AsyncSession):
    reset_q = """reset session authorization"""
    if get_app_settings().APP_ENV in ["dev", "test"]:
        logger.info("reset")
    await db.execute(text(reset_q))
