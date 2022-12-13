import sqlalchemy as sa
from sqlalchemy import func
from sqlalchemy.dialects import postgresql as ps
from sqlalchemy.orm import validates

from backend.app.db.base_class import Base
from backend.app.schemas import column_type


class User(Base):
    id = sa.Column(ps.BIGINT, primary_key=True, autoincrement=True)
    email = sa.Column(ps.TEXT, nullable=False, unique=True)
    hashed_password = sa.Column(ps.TEXT, nullable=False)
    role = sa.Column(column_type.userRolePostgresEnum, nullable=False)
    full_name = sa.Column(ps.TEXT)
    username = sa.Column(ps.TEXT, nullable=False, unique=True)
    avatar = sa.Column(ps.TEXT, default=None)
    is_active = sa.Column(ps.BOOLEAN, default=True)
    is_superuser = sa.Column(ps.BOOLEAN, default=False)
    create_date = sa.Column(sa.DateTime(timezone=True), server_default=func.now())

    # noinspection PyUnusedLocal
    @validates("email")
    def validate_email(self, key, value):
        if "@" not in value:
            raise ValueError("failed simple email validation")
        return value

    # noinspection PyUnusedLocal
    @validates("username")
    def validate_username(self, key, value):
        return value.lower().replace(' ', '_').replace('@', '').replace('$', '')
