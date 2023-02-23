import json
from collections.abc import Callable
from datetime import datetime
from typing import Any
from typing import Optional

from app.schemas import RequestParams
from fastapi import HTTPException
from fastapi import Query
from sqlalchemy import and_
from sqlalchemy import asc
from sqlalchemy import desc
from sqlalchemy.orm import DeclarativeMeta


def parse_react_admin_params(
    model: DeclarativeMeta | Any,
) -> Callable[[str | None, str | None], RequestParams]:
    """Parses sort and range parameters coming from a react-admin request"""

    def inner(
        sort_: Optional[str] = Query(
            None,
            alias="sort",
            description='Format: `["field_name", "direction"]`',
            example='["id", "ASC"]',
        ),
        range_: Optional[str] = Query(
            None,
            alias="range",
            description="Format: `[start, end]`",
            example="[0, 10]",
        ),
        filter_: Optional[str] = Query(
            None,
            alias="filter",
            description='Format: `{"id": 0}`',
        ),
    ):
        skip, limit = 0, 50
        if range_:
            start, end = json.loads(range_)
            skip, limit = start, (end - start + 1)

        order_by = desc(model.id)
        if sort_:
            sort_column, sort_order = json.loads(sort_)
            if sort_order.lower() == "asc":
                direction = asc
            elif sort_order.lower() == "desc":
                direction = desc
            else:
                raise HTTPException(400, f"Invalid sort direction {sort_order}")
            order_by = direction(model.__table__.c[sort_column])
        filter_by = None
        if filter_:
            ft: dict = json.loads(filter_)
            if len(ft) > 0:
                fb = []
                filter_dict: dict = dict(
                    filter(lambda it: str(it[0]).isdigit() is False, ft.items()),
                )
                for k, v in filter_dict.items():
                    if v is None:
                        fb.append(model.__table__.c[k] == None)  # noqa
                    elif isinstance(v, str):
                        if k:  # in enums.pg_custom_type_colnames
                            fb.append(model.__table__.c[k] == v)
                        else:
                            if str(k).split("_")[-1] == "date":
                                fb.append(
                                    model.__table__.c[k] >= datetime.fromisoformat(v),
                                )
                            else:
                                fb.append(model.__table__.c[k].ilike(f"{v}%"))
                    elif isinstance(v, int):
                        fb.append(model.__table__.c[k] == v)
                    elif isinstance(v, list) and isinstance(v[0], list):
                        fb.append(model.__table__.c[k].in_(tuple(v[0])))
                    elif isinstance(v, list):
                        if all(str(x).isdigit() for x in v):
                            v = [int(x) for x in v]
                        fb.append(model.__table__.c[k].in_(tuple(v)))
                    else:
                        raise HTTPException(400, f"Invalid filters {filter_dict}")
                if len(fb) > 0:
                    filter_by = and_(*fb)

        return RequestParams(
            skip=skip,
            limit=limit,
            order_by=order_by,
            filter_by=filter_by,
        )

    return inner
