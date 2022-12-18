import asyncio

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection
from tenacity import after_log, before_log, retry, stop_after_attempt, wait_fixed

from backend.app.db.session import engine
from backend.app.main import logger

max_tries = 60 * 5  # 5 minutes
wait_seconds = 1


@retry(
    stop=stop_after_attempt(max_tries),
    wait=wait_fixed(wait_seconds),
    before=before_log(logger, 20),
    after=after_log(logger, 30),
)
async def init() -> None:
    try:
        async with engine.connect() as conn:
            conn: AsyncConnection
            try:
                result = await conn.execute(text("SELECT * from version()"))
                logger.info(f'db version: {result.scalar()}')
            except Exception as e:
                logger.info(f'backend_pre_start: Exception: {e.args}')
                await conn.rollback()
                await conn.close()
    except Exception as e:
        logger.error(e)
        raise e


def main() -> None:
    logger.info("Initializing service")
    asyncio.run(init())
    logger.info("Service finished initializing")


if __name__ == "__main__":
    main()
