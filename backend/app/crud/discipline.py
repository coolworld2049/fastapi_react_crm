from backend.app.crud.base import CRUDBase
from backend.app.db.models import Discipline
from backend.app.schemas import DisciplineCreate, DisciplineUpdate


class CRUDDiscipline(CRUDBase[Discipline, DisciplineCreate, DisciplineUpdate]):
    pass


discipline = CRUDDiscipline(Discipline)

