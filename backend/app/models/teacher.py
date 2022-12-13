import sqlalchemy as sa
from sqlalchemy import func
from sqlalchemy.dialects import postgresql as ps

from backend.app.db.base_class import Base

'''
id bigserial primary key,
    discipline_id bigint references discipline(id) not null,
    user_id bigint references "user"(id) not null,
    create_date timestamp with time zone default localtimestamp
'''
class Teacher(Base):
    id = sa.Column(ps.BIGINT, primary_key=True, autoincrement=True)
    discipline_id = sa.Column(sa.ForeignKey('discipline.id'), nullable=False)
    user_id = sa.Column(sa.ForeignKey('user.id'), nullable=False)
    create_date = sa.Column(sa.DateTime(timezone=True), server_default=func.now())
