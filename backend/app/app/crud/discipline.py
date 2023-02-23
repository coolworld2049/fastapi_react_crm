from app.crud.base import CRUDBase
from app.models.domain import Discipline
from app.schemas import DisciplineCreate, DisciplineUpdate


class CRUDDiscipline(CRUDBase[Discipline, DisciplineCreate, DisciplineUpdate]):
    pass


discipline = CRUDDiscipline(Discipline)
