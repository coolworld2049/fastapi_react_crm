from app.models import EnumMixin


class UserRole(str, EnumMixin):
    admin = "admin"
    user = "user"
    student = "student"
    teacher = "teacher"


class StudentRole(str, EnumMixin):
    student = "student"
    leader = "leader"


class TeacherRole(str, EnumMixin):
    lecturer = "lecturer"
    practicioner = "practicioner"


class TaskStatus(str, EnumMixin):
    unassigned = "unassigned"
    pending = "pending"
    started = "started"
    verifying = "verifying"
    accepted = "accepted"
    overdue = "overdue"
    completed = "completed"


class TaskPriority(str, EnumMixin):
    high = "high"
    medium = "medium"
    low = "low"


class StudentTaskGrade(str, EnumMixin):
    good = "good"
    great = "great"
    normal = "normal"
    bad = "bad"
    passed = "passed"
    not_passed = "not_passed"


instances = {
    UserRole.snake_case_name(): UserRole.to_list(),
    StudentRole.snake_case_name(): StudentRole.to_list(),
    TeacherRole.snake_case_name(): TeacherRole.to_list(),
    TaskStatus.snake_case_name(): TaskStatus.to_list(),
    TaskPriority.snake_case_name(): TaskPriority.to_list(),
    StudentTaskGrade.snake_case_name(): StudentTaskGrade.to_list(),
}
