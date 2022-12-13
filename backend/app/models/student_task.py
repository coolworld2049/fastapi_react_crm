import sqlalchemy as sa
from sqlalchemy import func
from sqlalchemy.dialects import postgresql as ps

from backend.app.db.base_class import Base
from backend.app.schemas import column_type

'''
task_id bigint references task(id) primary key not null,
    points smallint,
    "comment" text,
    feedback text,
    grade task_grade_type,
    deadline_date timestamp with time zone,
    start_date timestamp with time zone,
    completion_date timestamp with time zone,
    constraint c_data check ( student_task.completion_date < student_task.deadline_date )
'''
class StudentTask(Base):
    task_id = sa.Column(ps.BIGINT, sa.ForeignKey('task.id'), nullable=False)
    points = sa.Column(ps.SMALLINT)
    comment = sa.Column(ps.TEXT)
    feedback = sa.Column(ps.TEXT)
    grade = sa.Column(ps.TEXT)
    deadline_date = sa.Column(sa.DateTime(timezone=True))
    start_date = sa.Column(sa.DateTime(timezone=True))
    completion_date = sa.Column(sa.DateTime(timezone=True))
    sa.CheckConstraint("student_task.completion_date < student_task.deadline_date", name="c_date"),
