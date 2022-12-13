import sqlalchemy as sa
from sqlalchemy import func
from sqlalchemy.dialects import postgresql as ps

from backend.app.db.base_class import Base

'''
id bigserial primary key,
    discipline_id bigint references discipline(id) not null,
    "type" discipline_type not null,
    classroom_number text not null,
    campus_id text references campus(id) not null,
    create_date timestamp with time zone default localtimestamp
'''
class DisciplineTyped(Base):
    id = sa.Column(sa.ForeignKey('discipline.id'), primary_key=True)
    type = sa.Column(ps.TEXT, nullable=False)
    classroom_number = sa.Column(ps.TEXT, nullable=False)
    campus_id = sa.Column(sa.ForeignKey('campus.id'), nullable=False)
    create_date = sa.Column(sa.DateTime(timezone=True), server_default=func.now())
