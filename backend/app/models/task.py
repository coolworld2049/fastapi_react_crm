import sqlalchemy as sa
from sqlalchemy.dialects import postgresql as ps

from backend.app.db.base_class import Base
from backend.app.schemas import column_type


class Task(Base):
    id = sa.Column(ps.INTEGER, primary_key=True, autoincrement=True)
    client_id = sa.Column(ps.INTEGER, sa.ForeignKey('client.id'), nullable=False)
    author_id = sa.Column(ps.INTEGER, sa.ForeignKey('user.id'), nullable=False)
    executor_id = sa.Column(ps.INTEGER, sa.ForeignKey('user.id'))
    name = sa.Column(ps.TEXT)
    description = sa.Column(ps.TEXT)
    type = sa.Column(column_type.task_type)
    priority = sa.Column(column_type.priority, nullable=False)
    create_date = sa.Column(ps.TIMESTAMP, nullable=False)
    deadline_date = sa.Column(ps.TIMESTAMP)
    completion_date = sa.Column(ps.TIMESTAMP)
