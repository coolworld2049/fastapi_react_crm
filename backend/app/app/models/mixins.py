import re
from enum import Enum

import sqlalchemy as sa


class TimestampsMixin:
    """Mixin that define timestamp columns."""

    __abstract__ = True

    __created_at_name__ = "created_at"
    __updated_at_name__ = "updated_at"
    __datetime_func__ = sa.func.now()

    created_at = sa.Column(
        __created_at_name__,
        sa.TIMESTAMP(timezone=True),
        default=__datetime_func__,
        nullable=True,
    )

    updated_at = sa.Column(
        __updated_at_name__,
        sa.TIMESTAMP(timezone=True),
        default=__datetime_func__,
        onupdate=__datetime_func__,
        nullable=True,
    )


class EnumMixin(Enum):
    @classmethod
    def snake_case_name(cls):
        return re.sub(r"(?<!^)(?=[A-Z])", "_", str(cls.__name__)).lower()

    @classmethod
    def col_name(cls):
        return cls.snake_case_name().split("_")[-1]

    @classmethod
    def to_list(cls) -> list:
        return list(map(lambda c: c.value, cls))

    @classmethod
    def to_dict(cls) -> dict:
        return {cls.snake_case_name(): {c.name: c.value for c in cls}}
