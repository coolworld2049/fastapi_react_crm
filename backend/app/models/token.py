import sqlalchemy as sa
from sqlalchemy.dialects import postgresql as ps

from backend.app.db.base_class import Base


class Token(Base):
    user_id = sa.Column(sa.ForeignKey("user.id"), primary_key=True, nullable=False)
    token = sa.Column(ps.TEXT, unique=True)
    expires_in = sa.Column(ps.TIMESTAMP)
    scopes = sa.Column(ps.TEXT)
