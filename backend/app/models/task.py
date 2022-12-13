import sqlalchemy as sa
from sqlalchemy import func
from sqlalchemy.dialects import postgresql as ps

from backend.app.db.base_class import Base
from backend.app.schemas import column_type

'''
id bigserial primary key,
    teacher_id bigint references teacher(id) not null,
    study_group_base_id bigint references study_group_base(id) ,
    student_id bigint references student(id),
    title text not null,
    description text,
    status task_status not null default 'pending'::task_status,
    priority task_priority not null default 'medium'::task_priority,
    expiration_date timestamp with time zone not null,
    create_date timestamp with time zone default localtimestamp,
    constraint c_date check ( task.expiration_date >= task.create_date )
'''
class Task(Base):
    id = sa.Column(ps.BIGINT, primary_key=True, autoincrement=True)
    teacher_id = sa.Column(ps.INTEGER, sa.ForeignKey('teacher.id'), nullable=False)
    study_group_base_id = sa.Column(ps.INTEGER, sa.ForeignKey('study_group_base.id'))
    student_id = sa.Column(ps.INTEGER, sa.ForeignKey('student.id'))
    title = sa.Column(ps.TEXT, nullable=False)
    description = sa.Column(ps.TEXT)
    status = sa.Column(column_type.taskStatusPostgresEnum, nullable=False, default=column_type.taskStatus.pending)
    priority = sa.Column(column_type.taskPriorityPostgresEnum, nullable=False, default=column_type.taskPriority.medium)
    expiration_date = sa.Column(sa.DateTime(timezone=True), nullable=False)
    create_date = sa.Column(sa.DateTime(timezone=True), server_default=func.now())
    sa.CheckConstraint("task.expiration_date > task.create_date", name="c_date"),
