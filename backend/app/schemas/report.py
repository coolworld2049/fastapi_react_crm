from datetime import datetime
from typing import Optional

from pydantic import BaseModel
from pydantic.schema import Literal

from backend.app.core.config import settings


class ReportBase(BaseModel):
    start_timestamp: datetime = datetime.now(tz=settings.SERVER_TZ).replace(year=datetime.now().year - 1).isoformat(),
    end_timestamp: datetime = datetime.now(tz=settings.SERVER_TZ).replace(year=datetime.now().year + 1).isoformat(),


# Properties to receive via API on creation
class ReportCreate(ReportBase):
    ext: Literal['csv', 'json'] = 'json'


# Properties to receive via API on update
class ReportUpdate(ReportBase):
    pass


class ReportInDBBase(ReportBase):
    report_id: Optional[int] = None

    class Config:
        orm_mode = True


# Additional properties stored in DB but not returned by API
class ReportInDB(ReportInDBBase):
    pass


# Additional properties to return via API
class Report(ReportInDBBase):
    pass
