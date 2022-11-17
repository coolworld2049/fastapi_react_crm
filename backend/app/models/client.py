import sqlalchemy as sa
from sqlalchemy.dialects import postgresql as ps

from backend.app.db.base_class import Base
from backend.app.schemas import column_type


class Client(Base):
    id = sa.Column(ps.INTEGER, sa.ForeignKey('user.id'), primary_key=True)
    company_id = sa.Column(ps.INTEGER, sa.ForeignKey('company.id'), nullable=False)
    type = sa.Column(column_type.clientTypePostgresEnum, nullable=False)
