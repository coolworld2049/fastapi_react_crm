from sqlalchemy import Column, BIGINT
from sqlalchemy_mixins import AllFeaturesMixin

from app.db.session import Base


class BaseModel(Base, AllFeaturesMixin):
    __abstract__ = True
    id = Column(BIGINT, primary_key=True)
