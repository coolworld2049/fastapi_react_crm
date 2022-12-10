import sqlalchemy as sa
from sqlalchemy import func
from sqlalchemy.dialects import postgresql as ps

from backend.app.db.base_class import Base
from backend.app.schemas import column_type


class Task(Base):
    id = sa.Column(ps.INTEGER, primary_key=True, autoincrement=True)
    client_id = sa.Column(ps.INTEGER, sa.ForeignKey('user.id'), nullable=False)
    author_id = sa.Column(ps.INTEGER, sa.ForeignKey('user.id'), nullable=False)
    executor_id = sa.Column(ps.INTEGER, sa.ForeignKey('user.id'))
    name = sa.Column(ps.TEXT, nullable=False)
    description = sa.Column(ps.TEXT)
    status = sa.Column(column_type.taskStatusPostgresEnum, nullable=False, default=column_type.taskStatus.pending)
    priority = sa.Column(column_type.taskPriorityPostgresEnum, nullable=False, default=column_type.taskPriority.medium)
    create_date = sa.Column(sa.DateTime(timezone=True), server_default=func.now())
    deadline_date = sa.Column(sa.DateTime(timezone=True))
    completion_date = sa.Column(sa.DateTime(timezone=True))
