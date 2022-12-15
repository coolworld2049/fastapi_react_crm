# coding: utf-8
from sqlalchemy import BigInteger, Boolean, CheckConstraint, Column, DateTime, Enum, ForeignKey, SmallInteger, String, Table, Text, text
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()
metadata = Base.metadata


class Campu(Base):
    __tablename__ = 'campus'

    id = Column(Text, primary_key=True)
    address = Column(Text)


class Discipline(Base):
    __tablename__ = 'discipline'

    id = Column(BigInteger, primary_key=True, server_default=text("nextval('discipline_id_seq'::regclass)"))
    title = Column(Text, nullable=False)
    assessment = Column(Enum('test', 'test_diff', 'coursework', 'exam', name='type_assessment'))


class StudyGroupCipher(Base):
    __tablename__ = 'study_group_cipher'

    id = Column(String(30), primary_key=True)


class User(Base):
    __tablename__ = 'user'
    __table_args__ = (
        CheckConstraint('full_name <> (role)::text'),
        CheckConstraint('username <> (role)::text')
    )

    id = Column(BigInteger, primary_key=True, server_default=text("nextval('user_id_seq'::regclass)"))
    email = Column(Text, nullable=False, unique=True)
    hashed_password = Column(Text)
    role = Column(Enum('admin', 'anon', 'student', 'student_leader', 'student_leader_assistant', 'teacher', name='user_role'), nullable=False, server_default=text("'anon'::user_role"))
    full_name = Column(Text, index=True)
    username = Column(Text, nullable=False, unique=True)
    age = Column(SmallInteger)
    avatar = Column(Text)
    is_active = Column(Boolean, nullable=False, server_default=text("true"))
    is_superuser = Column(Boolean, nullable=False, server_default=text("false"))
    create_date = Column(DateTime(True), server_default=text("LOCALTIMESTAMP"))

    study_group_ciphers = relationship('StudyGroupCipher', secondary='student')


class UserContact(User):
    __tablename__ = 'user_contact'

    id = Column(ForeignKey('user.id'), primary_key=True)
    phone = Column(String(20), nullable=False)
    vk = Column(Text)
    telegram = Column(Text)
    discord = Column(Text)


t_user_student_view = Table(
    'user_student_view', metadata,
    Column('id', BigInteger),
    Column('email', Text),
    Column('hashed_password', Text),
    Column('role', Enum('admin', 'anon', 'student', 'student_leader', 'student_leader_assistant', 'teacher', name='user_role')),
    Column('full_name', Text),
    Column('username', Text),
    Column('age', SmallInteger),
    Column('avatar', Text),
    Column('is_active', Boolean),
    Column('is_superuser', Boolean),
    Column('create_date', DateTime(True)),
    Column('study_group_cipher_id', String(30))
)


t_user_teacher_view = Table(
    'user_teacher_view', metadata,
    Column('id', BigInteger),
    Column('discipline_id', BigInteger),
    Column('user_id', BigInteger),
    Column('full_name', Text),
    Column('email', Text),
    Column('role', Enum('admin', 'anon', 'student', 'student_leader', 'student_leader_assistant', 'teacher', name='user_role')),
    Column('username', Text),
    Column('age', SmallInteger),
    Column('avatar', Text),
    Column('create_date', DateTime(True))
)


class DisciplineTyped(Base):
    __tablename__ = 'discipline_typed'

    id = Column(BigInteger, primary_key=True, server_default=text("nextval('discipline_typed_id_seq'::regclass)"))
    discipline_id = Column(ForeignKey('discipline.id'), nullable=False)
    type = Column(Enum('lecture', 'practice', 'laboratory', 'project', 'consultation', 'test', 'test_diff', 'coursework', 'exam', name='type_discipline'), nullable=False)
    classroom_number = Column(Text, nullable=False)
    campus_id = Column(ForeignKey('campus.id'), nullable=False)
    create_date = Column(DateTime(True), server_default=text("LOCALTIMESTAMP"))

    campus = relationship('Campu')
    discipline = relationship('Discipline')


t_student = Table(
    'student', metadata,
    Column('id', ForeignKey('user.id'), primary_key=True),
    Column('study_group_cipher_id', ForeignKey('study_group_cipher.id'), nullable=False)
)


class StudyGroup(Base):
    __tablename__ = 'study_group'

    id = Column(BigInteger, primary_key=True, server_default=text("nextval('study_group_id_seq'::regclass)"))
    study_group_cipher_id = Column(ForeignKey('study_group_cipher.id'), nullable=False)
    discipline_id = Column(ForeignKey('discipline.id'), nullable=False)

    discipline = relationship('Discipline')
    study_group_cipher = relationship('StudyGroupCipher')


class Teacher(Base):
    __tablename__ = 'teacher'

    id = Column(BigInteger, primary_key=True, server_default=text("nextval('teacher_id_seq'::regclass)"))
    discipline_id = Column(ForeignKey('discipline.id'), nullable=False)
    user_id = Column(ForeignKey('user.id'), nullable=False)

    discipline = relationship('Discipline')
    user = relationship('User')


class Task(Base):
    __tablename__ = 'task'
    __table_args__ = (
        CheckConstraint('expiration_date >= create_date'),
    )

    id = Column(BigInteger, primary_key=True, server_default=text("nextval('task_id_seq'::regclass)"))
    teacher_id = Column(ForeignKey('teacher.id'), nullable=False)
    study_group_cipher_id = Column(ForeignKey('study_group_cipher.id'))
    student_id = Column(ForeignKey('student.id'))
    title = Column(Text, nullable=False)
    description = Column(Text)
    status = Column(Enum('unassigned', 'pending', 'started', 'verifying', 'accepted', 'overdue', 'completed', name='task_status'), nullable=False, server_default=text("'pending'::task_status"))
    priority = Column(Enum('high', 'medium', 'low', name='task_priority'), nullable=False, server_default=text("'medium'::task_priority"))
    expiration_date = Column(DateTime(True), nullable=False)
    create_date = Column(DateTime(True), server_default=text("LOCALTIMESTAMP"))

    student = relationship('Student')
    study_group_cipher = relationship('StudyGroupCipher')
    teacher = relationship('Teacher')


class StudentTask(Task):
    __tablename__ = 'student_task'
    __table_args__ = (
        CheckConstraint('completion_date < deadline_date'),
    )

    id = Column(ForeignKey('task.id'), primary_key=True)
    points = Column(SmallInteger)
    comment = Column(Text)
    feedback = Column(Text)
    grade = Column(Enum('good', 'great', 'normal', 'bad', 'passed', 'not_passed', name='student_task_grade'))
    deadline_date = Column(DateTime(True))
    start_date = Column(DateTime(True))
    completion_date = Column(DateTime(True))


class TaskStore(Base):
    __tablename__ = 'task_store'
    __table_args__ = (
        CheckConstraint('size <= 838860800'),
    )

    id = Column(BigInteger, primary_key=True, server_default=text("nextval('task_store_id_seq'::regclass)"))
    task_id = Column(ForeignKey('task.id'), nullable=False)
    url = Column(Text, nullable=False)
    size = Column(BigInteger, nullable=False)
    filename = Column(Text)
    media_type = Column(String(150))
    create_date = Column(DateTime(True), server_default=text("LOCALTIMESTAMP"))

    task = relationship('Task')
