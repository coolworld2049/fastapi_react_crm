import sqlalchemy as sa
from sqlalchemy import func
from sqlalchemy.dialects import postgresql as ps
from sqlalchemy.orm import validates

from backend.app.db.base_class import Base
from backend.app.schemas import column_type


class UserContact(Base):
    id = sa.Column(sa.ForeignKey('user.id'))
    phone = sa.Column(ps.VARCHAR(20))
    vk = sa.Column(ps.TEXT)
    telegram = sa.Column(ps.TEXT)
    discord = sa.Column(ps.TEXT)
