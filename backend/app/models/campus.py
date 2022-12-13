import sqlalchemy as sa
from sqlalchemy.dialects import postgresql as ps

from backend.app.db.base_class import Base

'''
id text primary key,
    address text
'''
class Campus(Base):
    id = sa.Column(ps.TEXT, primary_key=True)
    address = sa.Column(ps.TEXT)
