import asyncio
import logging

from backend.app.db.init_db import init_db


def main() -> None:
    logging.info("Creating initial data")
    asyncio.run(init_db())
    logging.info("Initial data created")


if __name__ == "__main__":
    main()
