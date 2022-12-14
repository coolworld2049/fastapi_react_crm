from backend.app.crud.base import CRUDBase
from backend.app.db.models import Campus
from backend.app.schemas import CampusCreate, CampusUpdate


class CRUDCampus(CRUDBase[Campus, CampusCreate, CampusUpdate]):
   pass


campus = CRUDCampus(Campus)
