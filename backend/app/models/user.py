import sqlalchemy as sa
from sqlalchemy.dialects import postgresql as ps

from backend.app.db.base_class import Base
from backend.app.schemas import column_type


class User(Base):
    id = sa.Column(ps.INTEGER, primary_key=True)
    email = sa.Column(ps.TEXT, nullable=False)
    hashed_password = sa.Column(ps.TEXT, nullable=False)
    role = sa.Column(column_type.userRolePostgresEnum, nullable=False)
    full_name = sa.Column(ps.TEXT)
    avatar = sa.Column(ps.TEXT, default=None)
    phone = sa.Column(ps.VARCHAR(20))
    is_active = sa.Column(ps.BOOLEAN, default=True)
    is_superuser = sa.Column(ps.BOOLEAN, default=False)
    create_date = sa.Column(sa.DateTime(timezone=True))

    def __repr__(self):
        return f"User(id={self.id!r}, email={self.email!r}, role={self.role!r})"
