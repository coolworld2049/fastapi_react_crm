import sqlalchemy as sa
from sqlalchemy import func
from sqlalchemy.dialects import postgresql as ps

from backend.app.db.base_class import Base

'''
id bigserial references "user"(id) primary key,
    study_group_base_id bigint references study_group_base(id) not null,
    create_date timestamp with time zone default localtimestamp
'''
class Student(Base):
    id = sa.Column(sa.ForeignKey('user.id'), primary_key=True)
    study_group_base_id = sa.Column(sa.ForeignKey('study_group_base.id'), nullable=False)
    create_date = sa.Column(sa.DateTime(timezone=True), server_default=func.now())
