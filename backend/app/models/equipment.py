import sqlalchemy as sa
from sqlalchemy.dialects import postgresql as ps

from backend.app.db.base_class import Base


class Equipment(Base):
    id = sa.Column(ps.INTEGER, primary_key=True)
    owner_id = sa.Column(ps.INTEGER, sa.ForeignKey("contract.id"))
    title = sa.Column(ps.TEXT)
    description = sa.Column(ps.TEXT)
