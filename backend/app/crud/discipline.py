from backend.app.crud.base import CRUDBase
from backend.app.db.models import Discipline, DisciplineTyped
from backend.app.schemas import DisciplineCreate, DisciplineUpdate, DisciplineTypedCreate, DisciplineTypedUpdate


class CRUDDiscipline(CRUDBase[Discipline, DisciplineCreate, DisciplineUpdate]):
   pass


discipline = CRUDDiscipline(Discipline)

class CRUDDisciplineTyped(CRUDBase[DisciplineTyped, DisciplineTypedCreate, DisciplineTypedUpdate]):
   pass


discipline_typed = CRUDDisciplineTyped(DisciplineTyped)
