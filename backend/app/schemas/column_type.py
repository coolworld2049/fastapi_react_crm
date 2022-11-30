from enum import Enum

from pydantic import BaseModel
from sqlalchemy.dialects import postgresql as ps


class ExtendedEnum(Enum):
    @classmethod
    def to_list(cls) -> list[str]:
        return list(map(lambda c: c.value, cls))

    @classmethod
    def class_name(cls) -> str:
        return cls.__name__


class UserRole(BaseModel):
    user: str
    admin_base: str
    manager_base: str
    ranker_base: str
    client_base: str


class ClientType(BaseModel):
    current: str
    potential: str


class TaskPriority(BaseModel):
    high: str
    medium: str
    low: str


class EquipmentStatus(BaseModel):
    accepted: str
    progress: str
    completed: str
    terminated: str


class CompanySize(BaseModel):
    individual: str
    small: str
    medium: str
    big: str
    huge: str


class ContractStage(BaseModel):
    generation: str
    negotiation: str
    routing: str
    approval: str
    storage: str


# ----------------------------------------------------------------------------------------------------------------------

userRole = UserRole(user='user',
                    admin_base='admin_base',
                    manager_base='manager_base',
                    ranker_base='ranker_base',
                    client_base='client_base')

clientType = ClientType(current='current',
                        potential='potential')


taskPriority = TaskPriority(high='high',
                            medium='medium',
                            low='low')

equipmentStatus = EquipmentStatus(accepted='accepted',
                                  progress='progress',
                                  completed='completed',
                                  terminated='terminated')

companySize = CompanySize(individual='individual',
                          small='small',
                          medium='medium',
                          big='big',
                          huge='huge')

contractStage = ContractStage(generation='generation',
                              negotiation='negotiation',
                              routing='routing',
                              approval='approval',
                              storage='storage')

# ----------------------------------------------------------------------------------------------------------------------

userRoleEnum = ExtendedEnum(value=UserRole.__name__, names=userRole.dict())

clientTypeEnum = ExtendedEnum(value=ClientType.__name__, names=clientType.dict())

taskPriorityEnum = ExtendedEnum(value=TaskPriority.__name__, names=taskPriority.dict())

equipmentStatusEnum = ExtendedEnum(value=EquipmentStatus.__name__, names=equipmentStatus.dict())

companySizeEnum = ExtendedEnum(value=CompanySize.__name__, names=companySize.dict())

contractStageEnum = ExtendedEnum(value=ContractStage.__name__, names=contractStage.dict())

# ----------------------------------------------------------------------------------------------------------------------

userRolePostgresEnum = ps.ENUM(*userRole.schema().get('required'), name=UserRole.__name__)

clientTypePostgresEnum = ps.ENUM(*clientType.schema().get('required'), name=ClientType.__name__)

taskPriorityPostgresEnum = ps.ENUM(*taskPriority.schema().get('required'), name=TaskPriority.__name__)

equipmentStatusPostgresEnum = ps.ENUM(*equipmentStatus.schema().get('required'), name=EquipmentStatus.__name__)

companySizePostgreseEnum = ps.ENUM(*companySize.schema().get('required'), name=CompanySize.__name__)

contractStagePostgreseEnum = ps.ENUM(*contractStage.schema().get('required'), name=ContractStage.__name__)
