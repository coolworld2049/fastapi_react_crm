from datetime import datetime

from pydantic import BaseModel
from pydantic.schema import Literal


class ReportBase(BaseModel):
    #  = datetime.now().replace(year=datetime.now().year - 1).isoformat()
    start_timestamp: datetime
    end_timestamp: datetime


# Properties to receive via API on creation
class ReportCreate(ReportBase):
    id: int
    ext: Literal['csv', 'json'] = 'json'


# Properties to receive via API on update
class ReportUpdate(ReportBase):
    pass


class ReportInDBBase(ReportBase):
    pass


# Additional properties stored in DB but not returned by API
class ReportInDB(ReportInDBBase):
    pass


# Additional properties to return via API
class Report(ReportInDBBase):
    pass
