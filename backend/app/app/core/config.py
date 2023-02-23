from functools import lru_cache
from typing import Dict
from typing import Type

from app.core.settings.app import AppSettings
from app.core.settings.base import AppEnvTypes
from app.core.settings.base import BaseAppSettings
from app.core.settings.development import DevAppSettings
from app.core.settings.production import ProdAppSettings
from app.core.settings.test import TestAppSettings

environments: Dict[AppEnvTypes, Type[AppSettings]] = {
    AppEnvTypes.dev: DevAppSettings,
    AppEnvTypes.prod: ProdAppSettings,
    AppEnvTypes.test: TestAppSettings,
}


@lru_cache
def get_app_settings() -> AppSettings:
    app_env: AppEnvTypes = BaseAppSettings().APP_ENV
    config = environments[app_env]
    return config()
