import sqlalchemy as sa
from sqlalchemy.dialects import postgresql as ps

from backend.app.db.base_class import Base

'''
id bigserial primary key,
    cipher varchar(30)
'''
class StudyGroupBase(Base):
    id = sa.Column(ps.BIGINT, primary_key=True, autoincrement=True)
    cipher = sa.Column(ps.VARCHAR(30))
