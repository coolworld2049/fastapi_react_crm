import sqlalchemy as sa
from sqlalchemy.dialects import postgresql as ps

from backend.app.db.base_class import Base

'''
id bigserial primary key,
    study_group_base_id bigint references study_group_base(id) not null,
    discipline_id bigint references discipline(id) not null
'''
class StudyGroup(Base):
    id = sa.Column(ps.BIGINT, primary_key=True, autoincrement=True)
    study_group_base_id = sa.Column(sa.ForeignKey('study_group_base.id'), nullable=False)
    discipline_id =sa.Column(sa.ForeignKey('discipline.id'), nullable=False)
