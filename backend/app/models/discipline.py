import sqlalchemy as sa
from sqlalchemy.dialects import postgresql as ps

from backend.app.db.base_class import Base

'''
id bigserial primary key,
    title text not null,
    assessment_type assessment_type
'''
class Discipline(Base):
    id = sa.Column(ps.BIGINT, primary_key=True, autoincrement=True)
    title = sa.Column(ps.TEXT, nullable=False)
    assessment_type = sa.Column(ps.TEXT)
