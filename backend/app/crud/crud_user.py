from typing import Any, Dict, Optional, Union

from sqlalchemy.orm import Session

from backend.app.core.security import get_password_hash, verify_password
from backend.app.crud.base import CRUDBase
from backend.app.models.user import User
from backend.app.schemas.user import UserCreate, UserUpdate


class CRUDUser(CRUDBase[User, UserCreate, UserUpdate]):

    def get_by_email(self, db: Session, *, email: str) -> Optional[User]:  # noqa
        return db.query(User).filter(User.email == email).first()

    def create(self, db: Session, *, obj_in: UserCreate) -> User:
        create_data = obj_in.dict()
        create_data.pop("password")
        db_obj = User(**create_data)
        db_obj.hashed_password = get_password_hash(obj_in.password)
        db.add(db_obj)
        db.commit()

        return db_obj

    def update(
            self, db: Session, *, db_obj: User, obj_in: Union[UserUpdate, Dict[str, Any]]
    ) -> User:
        if isinstance(obj_in, dict):
            update_data = obj_in
        else:
            update_data = obj_in.dict(exclude_unset=True)

        return super().update(db, db_obj=db_obj, obj_in=update_data)

    def is_active(self, user: User) -> bool:  # noqa
        return user.is_active

    def is_superuser(self, user: User) -> bool: # noqa
        return user.is_superuser


user = CRUDUser(User)


def authenticate(
        *,
        email: str,
        password: str,
        db: Session,
) -> Optional[User]:
    user = db.query(User).filter(User.email == email).first() # noqa
    if not user:
        return None
    if not verify_password(password, user.hashed_password):
        return None
    return user
