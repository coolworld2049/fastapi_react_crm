# coding: utf-8
from sqlalchemy import BigInteger, Boolean, CheckConstraint, Column, DateTime, Enum, ForeignKey, SmallInteger, String, \
    Table, Text, text, Sequence
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()
metadata = Base.metadata


class Campus(Base):
    __tablename__ = 'campus'

    id = Column(String(20), primary_key=True)
    address = Column(Text)


class Discipline(Base):
    __tablename__ = 'discipline'

    id = Column(BigInteger, primary_key=True)
    title = Column(Text, nullable=False)
    assessment = Column(Enum('test', 'exam', name='type_assessment'))

    study_group_cipher = relationship('StudyGroupCipher', secondary='study_group')


class StudyGroupCipher(Base):
    __tablename__ = 'study_group_cipher'

    id = Column(String(30), primary_key=True)


class User(Base):
    __tablename__ = 'user'
    __table_args__ = (
        CheckConstraint('full_name <> (role)::text'),
        CheckConstraint('username <> (role)::text')
    )

    id = Column(BigInteger, primary_key=True)
    email = Column(Text, nullable=False, unique=True)
    hashed_password = Column(Text)
    role = Column(Enum('admin', 'anon', 'student', 'teacher', name='user_role'), nullable=False, server_default=text("'anon'::user_role"))
    full_name = Column(Text)
    username = Column(Text, nullable=False, unique=True)
    age = Column(SmallInteger)
    phone = Column(String(20))
    avatar = Column(Text)
    is_online = Column(Boolean, server_default=text("true"))
    is_active = Column(Boolean, nullable=False, server_default=text("true"))
    is_superuser = Column(Boolean, nullable=False, server_default=text("false"))
    create_date = Column(DateTime(True), server_default=text("LOCALTIMESTAMP"))


class Student(Base):
    __tablename__ = 'student'

    id = Column(ForeignKey('user.id'), primary_key=True)
    role = Column(Enum('student', 'leader', name='student_role'), nullable=False)
    study_group_cipher_id = Column(String(30))

class StudyGroup(Base):
    __tablename__ = 'study_group'
    id = Column(ForeignKey('study_group_cipher.id'), primary_key=True, nullable=False)
    discipline_id = Column(ForeignKey('discipline.id'), primary_key=True, nullable=False)


class Teacher(Base):
    __tablename__ = 'teacher'

    id = Column(BigInteger, Sequence('teacher_id_seq'), nullable=False, unique=True)
    user_id = Column(ForeignKey('user.id'), primary_key=True, nullable=False)
    role = Column(Enum('lecturer', 'practicioner', name='teacher_role'), primary_key=True, nullable=False)
    discipline_id = Column(ForeignKey('discipline.id'), primary_key=True, nullable=False)
    room_number = Column(String(10))
    campus_id = Column(ForeignKey('campus.id'))

    campus = relationship('Campus')
    discipline = relationship('Discipline')
    user = relationship('User')


class Task(Base):
    __tablename__ = 'task'

    id = Column(BigInteger, Sequence('task_id_seq'), nullable=False, unique=True)
    teacher_id = Column(ForeignKey('teacher.id'), primary_key=True, nullable=False)
    title = Column(Text, primary_key=True, nullable=False)
    description = Column(Text)
    priority = Column(Enum('high', 'medium', 'low', name='task_priority'), nullable=False, server_default=text("'medium'::task_priority"))
    create_date = Column(DateTime(True), server_default=text("LOCALTIMESTAMP"))

    teacher = relationship('Teacher')


class StudentTask(Base):
    __tablename__ = 'student_task'
    __table_args__ = (
        CheckConstraint('completion_date < deadline_date'),
    )

    id = Column(ForeignKey('task.id'), primary_key=True, nullable=False)
    student_id = Column(ForeignKey('student.id'), primary_key=True, nullable=False)
    status = Column(Enum('unassigned', 'pending', 'started', 'verifying', 'accepted', 'overdue', 'completed', name='task_status'), nullable=False, server_default=text("'pending'::task_status"))
    points = Column(SmallInteger)
    comment = Column(Text)
    feedback = Column(Text)
    grade = Column(Enum('good', 'great', 'normal', 'bad', 'passed', 'not_passed', name='task_grade_type'))
    deadline_date = Column(DateTime(True))
    completion_date = Column(DateTime(True))

    task = relationship('Task')
    student = relationship('Student')


class StudentTaskStore(Base):
    __tablename__ = 'student_task_store'
    __table_args__ = (
        CheckConstraint('size <= 160000000'),
    )

    id = Column(BigInteger, Sequence('student_task_store_id_seq'), nullable=False, unique=True)
    task_id = Column(ForeignKey('task.id'), primary_key=True, nullable=False)
    student_id = Column(ForeignKey('student.id'), primary_key=True, nullable=False)
    url = Column(Text, primary_key=True, nullable=False)
    size = Column(BigInteger, nullable=False)
    filename = Column(Text)
    create_date = Column(DateTime(True), server_default=text("LOCALTIMESTAMP"))

    student = relationship('Student')
    task = relationship('Task')


class StudyGroupTask(Base):
    __tablename__ = 'study_group_task'

    id = Column(ForeignKey('task.id'), primary_key=True, nullable=False)
    study_group_cipher_id = Column(ForeignKey('study_group_cipher.id'), primary_key=True, nullable=False)
    status = Column(Enum('unassigned', 'pending', 'started', 'verifying', 'accepted', 'overdue', 'completed', name='task_status'), nullable=False, server_default=text("'accepted'::task_status"))
    deadline_date = Column(DateTime(True))

    task = relationship('Task')
    study_group_cipher = relationship('StudyGroupCipher')
