from backend.app import schemas


class TeacherStudyGroupDiscipline(schemas.StudyGroupInDB, schemas.TeacherBase):
    pass


# Properties to receive via API on update
class TeacherStudyGroupDisciplineUpdate(TeacherStudyGroupDiscipline):
    pass
