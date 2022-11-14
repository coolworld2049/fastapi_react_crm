import logging
from datetime import datetime

from sqlalchemy.orm import Session

from backend.app import crud, schemas
from backend.app.db import base  # noqa: F401
from backend.app.core.config import settings
from backend.app.db.base_class import Base
from backend.app.db.session import engine
from backend.app.schemas import column_type

logger = logging.getLogger(__name__)


# make sure all SQL Alchemy models are imported (app.db.base) before initializing DB
# otherwise, SQL Alchemy might fail to initialize relationships properly
# for more details: https://github.com/tiangolo/full-stack-fastapi-postgresql/issues/28


def init_db(db: Session) -> None:
    # Tables should be created with Alembic migrations
    # But if you don't want to use migrations, create
    # the tables un-commenting the next line
    Base.metadata.create_all(bind=engine)

    user = crud.user.get_by_email(db, email=settings.FIRST_SUPERUSER_USERNAME)
    if not user:
        user_in = schemas.UserCreate(
            email=settings.FIRST_SUPERUSER_USERNAME,
            password=settings.FIRST_SUPERUSER_PASSWORD,
            is_superuser=True,
            first_name='John',
            last_name='Doe',
            phone='+79998880001',
            role=column_type.user_role_inst.admin,
            create_date=datetime.today()
        )
        user = crud.user.create(db, obj_in=user_in)  # noqa: F841
