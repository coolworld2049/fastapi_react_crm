import typing

from sqlalchemy.ext.declarative import as_declarative, declared_attr

class_registry: typing.Dict = {}


@as_declarative(class_registry=class_registry)
class Base:
    id: typing.Any
