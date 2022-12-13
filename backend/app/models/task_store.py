import sqlalchemy as sa
from sqlalchemy import func
from sqlalchemy.dialects import postgresql as ps

from backend.app.db.base_class import Base
from backend.app.schemas import column_type

'''
id bigserial primary key,
    task_id bigint references task(id) not null,
    url text not null,
    size bigint constraint c_file_size check ( size <= 838860800 ) not null, --100mb
    filename text,
    media_type varchar(150),
    create_date timestamp with time zone default localtimestamp
'''
class TaskStore(Base):
    id = sa.Column(ps.BIGINT, primary_key=True, autoincrement=True)
    task_id = sa.Column(ps.BIGINT, sa.ForeignKey('task.id'), nullable=False)
    url = sa.Column(ps.TEXT, nullable=False)
    size = sa.Column(ps.BIGINT)
    filename = sa.Column(ps.TEXT)
    media_type = sa.Column(ps.VARCHAR(150))
    create_date = sa.Column(sa.DateTime(timezone=True), server_default=func.now())
