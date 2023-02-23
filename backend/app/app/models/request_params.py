from typing import Any
from typing import Optional

from pydantic.main import BaseModel


class RequestParams(BaseModel):
    skip: Optional[int]
    limit: Optional[int]
    order_by: Any
    filter_by: Any
