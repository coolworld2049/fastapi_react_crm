import uvicorn

from app.core.config import get_app_settings
from app.main import project_static_html_path

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        port=get_app_settings().PORT,
        reload=True,
        reload_dirs=project_static_html_path.__str__(),
    )
