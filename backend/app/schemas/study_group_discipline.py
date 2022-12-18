from backend.app import schemas


class StudyGroupDiscipline(schemas.StudyGroup, schemas.Discipline):
    pass


# Properties to receive via API on update
class StudyGroupDisciplineUpdate(StudyGroupDiscipline):
    pass
