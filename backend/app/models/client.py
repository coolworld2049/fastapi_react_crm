import sqlalchemy as sa
from sqlalchemy.dialects import postgresql as ps

from backend.app.db.base_class import Base
from backend.app.schemas import column_type


class Client(Base):
    id = sa.Column(ps.INTEGER, primary_key=True)
    company_id = sa.Column(ps.INTEGER, sa.ForeignKey('company.id'), nullable=False)
    phone = sa.Column(ps.VARCHAR(20), nullable=False)
    type = sa.Column(column_type.client_type, nullable=False)
    create_date = sa.Column(sa.TIMESTAMP)
