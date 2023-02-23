from app.core.settings.app import AppSettings


class TestAppSettings(AppSettings):
    title: str = "Test FastAPI example application"

    DEBUG: bool = True
    JWT_SECRET_KEY: str
    LOGGING_LEVEL: str = "DEBUG"

    class Config(AppSettings.Config):
        env_file = ".env"
