import json
import logging
from datetime import datetime
from typing import Optional, Callable, Any, AsyncGenerator

from asyncpg import Connection
from fastapi import Depends, status
from fastapi import HTTPException, Query
from jose import jwt, JWTError
from sqlalchemy import asc, desc, text, and_
from sqlalchemy.engine import Result
from sqlalchemy.ext.asyncio.session import AsyncSession
from sqlalchemy.orm import DeclarativeMeta

from backend.app import crud, schemas
from backend.app.core.config import settings
from backend.app.core.security import oauth2Scheme
from backend.app.db import User, classifiers
from backend.app.db.session import asyncpg_database, AsyncSessionFactory
from backend.app.schemas.request_params import RequestParams


async def get_db() -> AsyncGenerator:
    async with AsyncSessionFactory() as session:
        session.current_user_id = None
        yield session


async def get_current_user_async(
        db: AsyncSession = Depends(get_db),
        token: str = Depends(oauth2Scheme)
) -> User:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM],
            options={"verify_aud": False},
        )
        subject: str = payload.get("sub")
        scopes: str = payload.get("scopes")
        if not subject:
            raise credentials_exception
        token_data = schemas.TokenPayload(sub=subject, scopes=scopes)
    except JWTError:
        raise credentials_exception
    if not token_data.sub.isdigit():
        raise credentials_exception
    user = await crud.user.get_by_id(db=db, id=int(token_data.sub))
    if user is None:
        raise credentials_exception

    logging.info('START')
    db_user = user.username
    await get_session_user(db)
    await reset_session_user(db)
    await get_session_user(db)
    check_result = await check_rolname(db, db_user)
    if not check_result:
        conn = await asyncpg_database.get_connection()
        await create_user_in_role(conn, user, db_user)
    await reset_session_user(db)
    await get_session_user(db)
    await set_session_user(db, db_user)
    await get_session_user(db)
    logging.info('END')

    return user


async def check_rolname(db: AsyncSession, db_user: str):
    check_q = """select rolname from pg_roles where rolname = :db_user"""
    check_q_result: Result = await db.execute(text(check_q), {'db_user': db_user})
    check_result = check_q_result.scalar()
    logging.info(f"check_rolname: {f'{db_user} role exist' if check_result else f'{db_user} role not exist'}")
    return check_result


async def create_user_in_role(db: AsyncSession | Connection, current_user: User, db_user: str):
    _create_db_user_q = """create user """ + db_user + """ inherit login password '""" + current_user.hashed_password \
                       + """' valid until 'infinity' in role """ + current_user.role
    create_db_user_q = "create user :db_user inherit login password :hashed_password valid until 'infinity'" \
                       " in role :current_user_role"
    params = {
        'db_user': db_user,
        'hashed_password': current_user.hashed_password,
        'current_user_role': current_user.role
    }
    if isinstance(db, Connection):
        await db.execute(create_db_user_q)
    elif isinstance(db, AsyncSession):
        await db.execute(text(create_db_user_q), params)
    logging.info(f'CREATE_user_in_role: {db_user}')

async def drop_user_in_role(db: AsyncSession | Connection, db_user: str):
    drop_db_user_q = """drop user """ + db_user
    if isinstance(db, Connection):
        await db.execute(drop_db_user_q)
    elif isinstance(db, AsyncSession):
        await db.execute(text(drop_db_user_q))
    logging.info(f'DROP_user_in_role: {db_user}')

async def get_session_user(db: AsyncSession):
    check_session_role_q = """select session_user, current_user"""
    check_session_role_q_result: Result = await db.execute(text(check_session_role_q))
    logging.info(f'get_session_user: {check_session_role_q_result.scalar()}')

async def set_session_user(db: AsyncSession, db_user: str):
    set_db_user_q = """set session authorization """ + db_user
    logging.info(f'SET_session_user: {db_user}')
    await db.execute(text(set_db_user_q))

async def reset_session_user(db: AsyncSession):
    reset_q = '''reset session authorization'''
    logging.info(f'RESET_session_user')
    await db.execute(text(reset_q))


async def get_current_active_user(
        current_user: User = Depends(get_current_user_async),
) -> User:
    if not crud.user.is_active(current_user):
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user


async def get_current_active_superuser(
        current_user: User = Depends(get_current_user_async),
) -> User:
    if not crud.user.is_superuser(current_user):
        raise HTTPException(
            status_code=400, detail="The user doesn't have enough privileges"
        )
    return current_user


def parse_react_admin_params(model: DeclarativeMeta | Any) -> Callable[[str | None, str | None], RequestParams]:
    """Parses sort and range parameters coming from a react-admin request"""

    def inner(
            sort_: Optional[str] = Query(
                None,
                alias="sort",
                description='Format: `["field_name", "direction"]`',
                example='["id", "ASC"]',
            ),
            range_: Optional[str] = Query(
                None,
                alias="range",
                description="Format: `[start, end]`",
                example="[0, 10]",
            ),
            filter_: Optional[str] = Query(
                None,
                alias="filter",
                description='Format: `{"k": "v"}`',
            ),

    ):
        skip, limit = 0, 10
        if range_:
            start, end = json.loads(range_)
            skip, limit = start, (end - start + 1)

        order_by = desc(model.id)  
        if sort_:
            sort_column, sort_order = json.loads(sort_)
            if sort_order.lower() == "asc":
                direction = asc
            elif sort_order.lower() == "desc":
                direction = desc
            else:
                raise HTTPException(400, f"Invalid sort direction {sort_order}")
            order_by = direction(model.__table__.c[sort_column])  
        filter_by = None
        if filter_:
            ft: dict = json.loads(filter_)
            if len(ft) > 0:
                fb = []
                filter_dict: dict = dict(filter(lambda it: str(it[0]).isdigit() is False, ft.items()))
                for k, v in filter_dict.items():
                    if isinstance(v, str):
                        if k in classifiers.pg_custom_type_colnames:
                            if v == "null":
                                fb.append(model.__table__.c[k] == None)  # noqa
                            else:
                                fb.append(model.__table__.c[k] == v)
                        else:
                            if str(k).split('_')[-1] == 'date':
                                fb.append(model.__table__.c[k] >= datetime.fromisoformat(v))
                            else:
                                fb.append(model.__table__.c[k].ilike(f'{v}%'))
                    elif isinstance(v, int):
                        fb.append(model.__table__.c[k] == v)
                    elif isinstance(v, list):
                        fb.append(model.__table__.c[k].in_(tuple(v)))
                filter_by = and_(*fb)

        return RequestParams(skip=skip, limit=limit, order_by=order_by, filter_by=filter_by)

    return inner
