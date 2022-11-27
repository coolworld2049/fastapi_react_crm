import sqlalchemy as sa
from sqlalchemy.dialects import postgresql as ps

from backend.app.db.base_class import Base
from backend.app.schemas import column_type


class Company(Base):
    id = sa.Column(ps.INTEGER, primary_key=True)
    name = sa.Column(ps.TEXT, nullable=False)
    sector = sa.Column(ps.TEXT)
    size = sa.Column(column_type.companySizePostgreseEnum)
    address = sa.Column(sa.TEXT)
    website = sa.Column(ps.TEXT)
    create_date = sa.Column(sa.TIMESTAMP(timezone=False))
