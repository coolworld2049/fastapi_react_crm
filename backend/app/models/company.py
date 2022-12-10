import sqlalchemy as sa
from sqlalchemy import func
from sqlalchemy.dialects import postgresql as ps

from backend.app.db.base_class import Base
from backend.app.schemas import column_type


class Company(Base):
    id = sa.Column(ps.INTEGER, primary_key=True)
    name = sa.Column(ps.TEXT, nullable=False)
    sector = sa.Column(ps.TEXT)
    size = sa.Column(column_type.companySizePostgreseEnum)
    city = sa.Column(sa.TEXT)
    address = sa.Column(sa.TEXT)
    website = sa.Column(ps.TEXT)
    create_date = sa.Column(sa.DateTime(timezone=True), server_default=func.now())
