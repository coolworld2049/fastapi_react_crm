from datetime import datetime

from pydantic import BaseModel
from pydantic.schema import Literal


class ReportBase(BaseModel):
    #  = datetime.now.replace(year=datetime.now.year - 1).isoformat()
    start_timestamp: datetime
    end_timestamp: datetime
    ext: Literal['csv', 'json'] = 'json'


# Properties to receive via API on creation
class ReportUserCreate(ReportBase):
    id: int
