from backend.app.crud.base import CRUDBase
from backend.app.db.models import Discipline, TypedDiscipline
from backend.app.schemas import DisciplineCreate, DisciplineUpdate, TypedDisciplineCreate, TypedDisciplineUpdate


class CRUDDiscipline(CRUDBase[Discipline, DisciplineCreate, DisciplineUpdate]):
    pass


discipline = CRUDDiscipline(Discipline)


class CRUDTypedDiscipline(CRUDBase[TypedDiscipline, TypedDisciplineCreate, TypedDisciplineUpdate]):
    pass


typed_discipline = CRUDTypedDiscipline(TypedDiscipline)
