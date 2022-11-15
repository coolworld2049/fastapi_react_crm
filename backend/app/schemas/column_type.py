from pydantic import BaseModel
from sqlalchemy.dialects import postgresql as ps


class UserRole(BaseModel):
    user: str
    admin: str
    manager: str
    ranker: str
    client: str

    @staticmethod
    def get_type_name():
        return 'user_role'


class ClientType(BaseModel):
    current: str
    potential: str

    @staticmethod
    def get_type_name():
        return 'client_type'


class Priority(BaseModel):
    high: str
    medium: str
    low: str

    @staticmethod
    def get_type_name():
        return 'priority'


class EquipmentStatus(BaseModel):
    accepted: str
    progress: str
    completed: str
    terminated: str

    @staticmethod
    def get_type_name():
        return 'equip_status'


class MarketSector(BaseModel):
    healthcare: str
    materials: str
    real_estate: str
    consumer_staples: str
    consumer_discretionary: str
    energy: str
    industrials: str
    consumer_services: str
    financials: str
    technology: str
    utilities: str

    @staticmethod
    def get_type_name():
        return 'market_sector'


class CompanySize(BaseModel):
    individual: str
    small: str
    medium: str
    big: str
    huge: str

    @staticmethod
    def get_type_name():
        return 'company_size'


class ContractStage(BaseModel):
    generation: str
    negotiation: str
    routing: str
    approval: str
    storage: str

    @staticmethod
    def get_type_name():
        return 'contract_stage'


class TaskType(BaseModel):
    website_design: str
    ui_design: str
    phone_call: str
    copywriting: str
    other: str

    @staticmethod
    def get_type_name():
        return 'task_type'


user_role_inst = UserRole(user='user', admin='admin', manager='manager', ranker='ranker', client='client')

client_type_inst = ClientType(current='current', potential='potential')

task_type_inst = TaskType(website_design='website_design',
                          ui_design='ui_design',
                          phone_call='phone_call',
                          copywriting='copywriting',
                          other='other')

priotity_inst = Priority(high='high', medium='medium', low='low')

equipment_status_inst = EquipmentStatus(accepted='accepted',
                                        progress='progress',
                                        completed='completed',
                                        terminated='terminated')

market_sector_inst = MarketSector(healthcare='healthcare',
                                  materials='materials',
                                  real_estate='real estate',
                                  consumer_staples='consumer staples',
                                  consumer_discretionary='consumer discretionary',
                                  energy='energy',
                                  industrials='industrials',
                                  consumer_services='consumer services',
                                  financials='financials',
                                  technology='technology',
                                  utilities='utilities')

company_size_inst = CompanySize(individual='1 employee',
                                small='2-9 employees',
                                medium='10-49 employees',
                                big='50-249 employees',
                                huge='250 or more employees')

contract_stage_inst = ContractStage(generation='generation',
                                    negotiation='negotiation',
                                    routing='routing',
                                    approval='approval',
                                    storage='storage')

user_role = ps.ENUM(*[x[1] for x in user_role_inst], name=UserRole.get_type_name(), )

client_type = ps.ENUM(*[x[1] for x in client_type_inst], name=ClientType.get_type_name(), )

task_type = ps.ENUM(*[x[1] for x in task_type_inst], name=TaskType.get_type_name(), )

priority = ps.ENUM(*[x[1] for x in priotity_inst], name=Priority.get_type_name(), )

equip_status = ps.ENUM(*[x[1] for x in equipment_status_inst], name=EquipmentStatus.get_type_name(), )

market_sector = ps.ENUM(*[x[1] for x in market_sector_inst], name=MarketSector.get_type_name(), )

company_size = ps.ENUM(*[x[1] for x in company_size_inst], name=CompanySize.get_type_name())

contract_stage = ps.ENUM(*[x[1] for x in contract_stage_inst], name=ContractStage.get_type_name())
