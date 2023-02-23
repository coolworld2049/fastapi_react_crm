from sqlalchemy import (
    BigInteger,
    Boolean,
    CheckConstraint,
    Column,
    DateTime,
    ForeignKey,
    SmallInteger,
    String,
    Text,
    text,
    Sequence,
    ForeignKeyConstraint,
)
from sqlalchemy.dialects.postgresql import ENUM
from sqlalchemy.orm import relationship

from app.models import BaseModel, TimestampsMixin, classifiers
from .classifiers import (
    StudentRole,
    TaskStatus,
    StudentTaskGrade,
    TaskPriority,
    UserRole,
)


class Campus(BaseModel):
    __tablename__ = "campus"

    id = Column(String(255), primary_key=True)
    address = Column(Text)


class Discipline(BaseModel):
    __tablename__ = "discipline"

    title = Column(Text, nullable=False)

    study_group_cipher = relationship("StudyGroupCipher", secondary="study_group")


class StudyGroupCipher(BaseModel):
    __tablename__ = "study_group_cipher"

    id = Column(String(30), primary_key=True)


class Student(BaseModel):
    __tablename__ = "student"

    id = Column(ForeignKey("user.id"), primary_key=True)
    role = Column(ENUM(*StudentRole.to_list(), name=StudentRole.snake_case_name()))
    study_group_cipher_id = Column(String(30))


class StudyGroup(BaseModel):
    __tablename__ = "study_group"

    id = Column(ForeignKey("study_group_cipher.id"), primary_key=True, nullable=False)
    discipline_id = Column(
        ForeignKey("discipline.id"), primary_key=True, nullable=False
    )


class Teacher(BaseModel):
    __tablename__ = "teacher"

    id = Column(BigInteger, Sequence("teacher_id_seq"), nullable=False, unique=True)
    user_id = Column(ForeignKey("user.id"), primary_key=True)
    role = Column(
        ENUM("lecturer", "practicioner", name="teacher_role"), primary_key=True
    )
    discipline_id = Column(ForeignKey("discipline.id"), primary_key=True)
    room_number = Column(String(10))
    campus_id = Column(ForeignKey("campus.id"))

    campus = relationship("Campus")
    discipline = relationship("Discipline")
    user = relationship("User")


class Task(BaseModel):
    __tablename__ = "task"
    __table_args__ = (
        ForeignKeyConstraint(
            ("teacher_user_id", "teacher_role", "teacher_discipline_id"),
            ("teacher.user_id", "teacher.role", "teacher.discipline_id"),
        ),
    )

    id = Column(BigInteger, Sequence("task_id_seq"), nullable=False, unique=True)
    teacher_user_id = Column(BigInteger, primary_key=True, nullable=False)
    teacher_role = Column(
        ENUM(
            *classifiers.TeacherRole.to_list(),
            name=classifiers.TeacherRole.snake_case_name(),
        ),
        primary_key=True,
        nullable=False,
    )
    teacher_discipline_id = Column(BigInteger, primary_key=True, nullable=False)
    title = Column(Text, primary_key=True, nullable=False)
    description = Column(Text)
    create_date = Column(DateTime(True), server_default=text("LOCALTIMESTAMP"))

    teacher_user = relationship("Teacher")


class StudentTask(BaseModel):
    __tablename__ = "student_task"
    __table_args__ = (CheckConstraint("completion_date <= deadline_date"),)

    id = Column(ForeignKey("task.id"), primary_key=True, nullable=False)
    student_id = Column(ForeignKey("student.id"), primary_key=True, nullable=False)
    status = Column(
        ENUM(*TaskStatus.to_list(), name=TaskStatus.snake_case_name()),
        nullable=False,
        server_default=text("'pending'::task_status"),
    )
    priority = Column(
        ENUM(*TaskPriority.to_list(), name=TaskPriority.snake_case_name()),
        nullable=False,
    )
    points = Column(SmallInteger)
    comment = Column(Text)
    grade = Column(
        ENUM(*StudentTaskGrade.to_list(), name=StudentTaskGrade.snake_case_name())
    )
    deadline_date = Column(DateTime(True))
    completion_date = Column(DateTime(True))

    task = relationship("Task")
    student = relationship("Student")


class StudentTaskStore(BaseModel):
    __tablename__ = "student_task_store"
    __table_args__ = (CheckConstraint("size <= 160000000"),)

    id = Column(
        BigInteger, Sequence("student_task_store_id_seq"), nullable=False, unique=True
    )
    task_id = Column(ForeignKey("task.id"), primary_key=True, nullable=False)
    student_id = Column(ForeignKey("student.id"), primary_key=True, nullable=False)
    url = Column(Text, primary_key=True, nullable=False)
    size = Column(BigInteger, nullable=False)
    filename = Column(Text)
    create_date = Column(DateTime(True), server_default=text("LOCALTIMESTAMP"))

    student = relationship("Student")
    task = relationship("Task")


class StudyGroupTask(BaseModel):
    __tablename__ = "study_group_task"

    id = Column(ForeignKey("task.id"), primary_key=True, nullable=False)
    study_group_cipher_id = Column(
        ForeignKey("study_group_cipher.id"), primary_key=True, nullable=False
    )
    status = Column(
        ENUM(*TaskStatus.to_list(), name=TaskStatus.snake_case_name()),
        nullable=False,
        server_default=text("'accepted'::task_status"),
    )
    deadline_date = Column(DateTime(True))

    task = relationship("Task")
    study_group_cipher = relationship("StudyGroupCipher")


class User(BaseModel, TimestampsMixin):
    __tablename__ = "user"
    email = Column(Text, nullable=False, unique=True)
    hashed_password = Column(Text)
    role = Column(
        ENUM(*UserRole.to_list(), name=UserRole.snake_case_name()),
        nullable=False,
        server_default=text(f"'{UserRole.user.name}'::{UserRole.snake_case_name()}"),
    )
    full_name = Column(Text)
    username = Column(Text, nullable=False, unique=True)
    age = Column(SmallInteger, server_default=None)
    phone = Column(String(20))
    avatar = Column(Text)
    is_active = Column(Boolean, nullable=False, server_default=text("true"))
    is_superuser = Column(Boolean, nullable=False, server_default=text("false"))
