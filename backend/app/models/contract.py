import sqlalchemy as sa
from sqlalchemy.dialects import postgresql as ps

from backend.app.db.base_class import Base
from backend.app.schemas import column_type


class Contract(Base):
    id = sa.Column(ps.INTEGER, primary_key=True)
    task_id = sa.Column(ps.INTEGER, sa.ForeignKey('task.id'), nullable=False)
    equipment_id = sa.Column(ps.INTEGER, sa.ForeignKey('equipment.id'), nullable=False)
    stage = sa.Column(column_type.contractStagePostgreseEnum)
    name = sa.Column(ps.TEXT)
    description = sa.Column(ps.TEXT)
    create_date = sa.Column(ps.TIMESTAMP(timezone=False), nullable=False)
    completion_date = sa.Column(ps.TIMESTAMP(timezone=False), nullable=False)
