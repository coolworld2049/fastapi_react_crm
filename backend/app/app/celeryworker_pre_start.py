import asyncio
import logging

from db.session import SessionLocal
from loguru import logger
from sqlalchemy import text
from tenacity import after_log
from tenacity import before_log
from tenacity import retry
from tenacity import stop_after_attempt
from tenacity import wait_fixed

max_tries = 60 * 5  # 5 minutes
wait_seconds = 1


@retry(
    stop=stop_after_attempt(max_tries),
    wait=wait_fixed(wait_seconds),
    before=before_log(logger, logging.INFO),
    after=after_log(logger, logging.WARN),
)
async def init() -> None:
    try:
        # Try to create session to check if DB is awake
        async with SessionLocal() as db:
            await db.execute(text("SELECT 1"))
    except Exception as e:
        logger.error(e)
        raise e


def main() -> None:
    logger.info("Initializing service")
    asyncio.run(init())
    logger.info("Service finished initializing")


if __name__ == "__main__":
    main()
