from typing import List, Tuple

from backend.app import schemas
from backend.app.crud.base import CRUDBase
from backend.app.db import models
from backend.app.db.models import StudyGroup, StudyGroupCipher
from backend.app.schemas import StudyGroupCreate, StudyGroupUpdate, StudyGroupCipherCreate, StudyGroupCipherUpdate


class CRUDStudyGroup(CRUDBase[StudyGroup, StudyGroupCreate, StudyGroupUpdate]):
    pass


study_group = CRUDStudyGroup(StudyGroup)


class CRUDStudyGroupCipher(CRUDBase[StudyGroupCipher, StudyGroupCipherCreate, StudyGroupCipherUpdate]):
    pass


study_group_cipher = CRUDStudyGroupCipher(StudyGroupCipher)


class CRUDStudyGroupDiscipline(CRUDBase[models.StudyGroupDiscipline, None, schemas.StudyGroupDisciplineUpdate]):
    async def get_multi(self, *args, **kwargs) -> Tuple[List[models.StudyGroupDiscipline], int]:
        return await super().get_multi(*args, **kwargs)


study_group_discipline = CRUDStudyGroupDiscipline(models.StudyGroupDiscipline)


class CRUDTeacherStudyGroupDiscipline(CRUDBase[models.TeacherStudyGroupDiscipline, None, schemas.TeacherStudyGroupDisciplineUpdate]):
    async def get_multi(self, *args, **kwargs) -> Tuple[List[models.TeacherStudyGroupDiscipline], int]:
        return await super().get_multi(*args, **kwargs)


teacher_study_group_discipline = CRUDTeacherStudyGroupDiscipline(models.TeacherStudyGroupDiscipline)
