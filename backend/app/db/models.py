from sqlalchemy import BigInteger, Boolean, CheckConstraint, Column, DateTime, ForeignKey, SmallInteger, String, \
    Text, text, select
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from sqlalchemy_utils import create_view

from backend.app.db.classifiers import user_role, type_assessment, discipline_type, task_status, task_priority, \
    student_task_grade
from sqlalchemy_mixins import AllFeaturesMixin

Base = declarative_base()
metadata = Base.metadata


class Campus(Base, AllFeaturesMixin):
    __tablename__ = 'campus'

    id = Column(Text, primary_key=True)
    address = Column(Text)


class Discipline(Base, AllFeaturesMixin):
    __tablename__ = 'discipline'

    id = Column(BigInteger, primary_key=True)
    title = Column(Text, nullable=False)
    assessment = Column(type_assessment)


class TypedDiscipline(Base, AllFeaturesMixin):
    __tablename__ = 'typed_discipline'

    id = Column(BigInteger, primary_key=True)
    discipline_id = Column(ForeignKey('discipline.id'), nullable=False)
    type = Column(discipline_type, nullable=False)
    classroom_number = Column(Text, nullable=False)
    campus_id = Column(ForeignKey('campus.id'), nullable=False)
    create_date = Column(DateTime(True), server_default=text("LOCALTIMESTAMP"))

    campus = relationship('Campus')
    discipline = relationship('Discipline')


class StudyGroupCipher(Base, AllFeaturesMixin):
    __tablename__ = 'study_group_cipher'

    id = Column(String(30), primary_key=True)


class User(Base, AllFeaturesMixin):
    __tablename__ = 'user'
    __table_args__ = (
        CheckConstraint('full_name <> (role)::text'),
        CheckConstraint('username <> (role)::text')
    )

    id = Column(BigInteger, primary_key=True)
    email = Column(Text, nullable=False, unique=True)
    hashed_password = Column(Text)
    role = Column(user_role, nullable=False, server_default=text("'anon'::user_role"))
    full_name = Column(Text)
    username = Column(Text, nullable=False, unique=True)
    age = Column(SmallInteger)
    avatar = Column(Text)
    phone = Column(Text)
    is_online = Column(Boolean, nullable=False, server_default=text("true"))
    is_active = Column(Boolean, nullable=False, server_default=text("true"))
    is_superuser = Column(Boolean, nullable=False, server_default=text("false"))
    create_date = Column(DateTime(True), server_default=text("LOCALTIMESTAMP"))

    study_group_ciphers = relationship('StudyGroupCipher', secondary='student')


class Student(Base, AllFeaturesMixin):
    __tablename__ = 'student'

    id = Column(ForeignKey('user.id'), primary_key=True)
    study_group_cipher_id = Column(ForeignKey('study_group_cipher.id'))


class StudyGroup(Base, AllFeaturesMixin):
    __tablename__ = 'study_group'

    id = Column(BigInteger, primary_key=True)
    study_group_cipher_id = Column(ForeignKey('study_group_cipher.id'), nullable=False)
    discipline_id = Column(ForeignKey('discipline.id'), nullable=False)

    discipline = relationship('Discipline')
    study_group_cipher = relationship('StudyGroupCipher')


class Teacher(Base, AllFeaturesMixin):
    __tablename__ = 'teacher'

    id = Column(BigInteger, primary_key=True)
    typed_discipline_id = Column(ForeignKey('typed_discipline.id'))
    user_id = Column(ForeignKey('user.id'), nullable=False)

    typed_discipline = relationship('TypedDiscipline')
    user = relationship('User')


class Task(Base, AllFeaturesMixin):
    __tablename__ = 'task'
    __table_args__ = (
        CheckConstraint('expiration_date >= create_date'),
    )

    id = Column(BigInteger, primary_key=True)
    teacher_id = Column(ForeignKey('teacher.id'), nullable=False)
    study_group_cipher_id = Column(ForeignKey('study_group_cipher.id'))
    student_id = Column(ForeignKey('student.id'))
    title = Column(Text, nullable=False)
    description = Column(Text)
    status = Column(task_status, nullable=False, server_default=text("'pending'::task_status"))
    priority = Column(task_priority, nullable=False, server_default=text("'medium'::task_priority"))
    expiration_date = Column(DateTime(True), nullable=False)
    create_date = Column(DateTime(True), server_default=text("LOCALTIMESTAMP"))

    student = relationship('Student')
    study_group_cipher = relationship('StudyGroupCipher')
    teacher = relationship('Teacher')


class TaskStudent(Base, AllFeaturesMixin):
    __tablename__ = 'student_task'
    __table_args__ = (
        CheckConstraint('completion_date < deadline_date'),
    )

    id = Column(ForeignKey('task.id'), primary_key=True)
    points = Column(SmallInteger)
    comment = Column(Text)
    feedback = Column(Text)
    grade = Column(student_task_grade)
    deadline_date = Column(DateTime(True))
    start_date = Column(DateTime(True))
    completion_date = Column(DateTime(True))


class TaskStore(Base, AllFeaturesMixin):
    __tablename__ = 'task_store'
    __table_args__ = (
        CheckConstraint('size <= 838860800'),
    )

    id = Column(BigInteger, primary_key=True)
    task_id = Column(ForeignKey('task.id'), nullable=False)
    url = Column(Text, nullable=False)
    size = Column(BigInteger, nullable=False)
    filename = Column(Text)
    media_type = Column(String(150))
    create_date = Column(DateTime(True), server_default=text("LOCALTIMESTAMP"))

    task = relationship('Task')


# StudyGroupCipher, Discipline
study_group_disciplines_statement = select(
    StudyGroup.id, StudyGroup.study_group_cipher_id, StudyGroup.discipline_id,
    Discipline.title, Discipline.assessment
).select_from(StudyGroupCipher) \
    .join(StudyGroup, StudyGroupCipher.id == StudyGroup.study_group_cipher_id) \
    .join(Discipline, Discipline.id == StudyGroup.discipline_id)

study_group_discipline_view = create_view('study_group_discipline_view', study_group_disciplines_statement, metadata)


class StudyGroupDiscipline(Base, AllFeaturesMixin):
    __table__ = study_group_discipline_view
