from typing import List, Tuple

from sqlalchemy import select
from sqlalchemy.engine import Result
from sqlalchemy.ext.asyncio import AsyncSession

from backend.app import schemas
from backend.app.crud.base import CRUDBase
from backend.app.db import models
from backend.app.db.models import StudyGroup, StudyGroupCipher
from backend.app.schemas import StudyGroupUpdate, StudyGroupCipherCreate, StudyGroupCipherUpdate, \
    StudyGroupDisciplineCreate


class CRUDStudyGroup(CRUDBase[StudyGroup, StudyGroupDisciplineCreate, StudyGroupUpdate]):
    async def create_with_disciplines(
            self, db: AsyncSession, obj_in: StudyGroupDisciplineCreate
    ) -> List[StudyGroup]:
        scg_id = obj_in.study_group_cipher_id
        for discipline_id in obj_in.discipline_id:
            _obj_in = schemas.StudyGroupCreate(
                study_group_cipher_id=scg_id,
                discipline_id=discipline_id
            )
            db_obj = self.model(**_obj_in.dict())
            db.add(db_obj)
            await db.commit()
            await db.refresh(db_obj)
        scg_db_obj: Result = await db.execute(select(self.model).where(self.model.study_group_cipher_id == scg_id))
        return scg_db_obj.scalars().all()


study_group = CRUDStudyGroup(StudyGroup)


class CRUDStudyGroupCipher(CRUDBase[StudyGroupCipher, StudyGroupCipherCreate, StudyGroupCipherUpdate]):
    pass


study_group_cipher = CRUDStudyGroupCipher(StudyGroupCipher)


class CRUDStudyGroupDiscipline(CRUDBase[models.StudyGroupDiscipline, None, schemas.StudyGroupDisciplineUpdate]):
    async def get_multi(self, *args, **kwargs) -> Tuple[List[models.StudyGroupDiscipline], int]:
        return await super().get_multi(*args, **kwargs)


study_group_discipline = CRUDStudyGroupDiscipline(models.StudyGroupDiscipline)

