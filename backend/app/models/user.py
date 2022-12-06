import sqlalchemy as sa
from sqlalchemy import func
from sqlalchemy.dialects import postgresql as ps
from sqlalchemy.orm import validates

from backend.app.db.base_class import Base
from backend.app.schemas import column_type


class User(Base):
    id = sa.Column(ps.INTEGER, primary_key=True)
    email = sa.Column(ps.TEXT, nullable=False)

    # noinspection PyUnusedLocal
    @validates("email")
    def validate_email(self, key, value):
        if "@" not in value:
            raise ValueError("failed simple email validation")
        return value

    hashed_password = sa.Column(ps.TEXT, nullable=False)
    role = sa.Column(column_type.userRolePostgresEnum, nullable=False)
    full_name = sa.Column(ps.TEXT)
    username = sa.Column(ps.TEXT)

    # noinspection PyUnusedLocal
    @validates("username")
    def validate_username(self, key, value):
        return value.lower().replace(' ', '_').replace('@', '').replace('$', '')

    avatar = sa.Column(ps.TEXT, default=None)
    phone = sa.Column(ps.VARCHAR(20))

    company_id = sa.Column(ps.INTEGER, sa.ForeignKey('company.id'), default=None)
    type = sa.Column(column_type.clientTypePostgresEnum, default=None, nullable=True)

    is_active = sa.Column(ps.BOOLEAN, default=True)
    is_superuser = sa.Column(ps.BOOLEAN, default=False)
    create_date = sa.Column(ps.TIMESTAMP(timezone=True), default=func.now(), server_default=func.now())

    def __repr__(self):
        return f"User(id={self.id!r}, email={self.email!r}, role={self.role!r})"
