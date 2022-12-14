from backend.app.crud.base import CRUDBase
from backend.app.db.models import StudyGroup, StudyGroupCipher
from backend.app.schemas import StudyGroupCreate, StudyGroupUpdate, StudyGroupCipherCreate, StudyGroupCipherUpdate


class CRUDStudyGroup(CRUDBase[StudyGroup, StudyGroupCreate, StudyGroupUpdate]):
   pass


study_group = CRUDStudyGroup(StudyGroup)

class CRUDStudyGroupCipher(CRUDBase[StudyGroupCipher, StudyGroupCipherCreate, StudyGroupCipherUpdate]):
   pass


study_group_cipher = CRUDStudyGroupCipher(StudyGroupCipher)
