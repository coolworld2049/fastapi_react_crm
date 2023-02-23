from app.crud.base import CRUDBase
from app.models.domain import Campus
from app.schemas import CampusCreate, CampusUpdate


class CRUDCampus(CRUDBase[Campus, CampusCreate, CampusUpdate]):
    pass


campus = CRUDCampus(Campus)
