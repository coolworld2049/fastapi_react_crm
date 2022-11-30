import asyncio

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection
from tenacity import after_log, before_log, retry, stop_after_attempt, wait_fixed

from backend.app.db.session import async_engine
from backend.app.main import logger

max_tries = 60 * 5  # 5 minutes
wait_seconds = 1


@retry(
    stop=stop_after_attempt(max_tries),
    wait=wait_fixed(wait_seconds),
    before=before_log(logger, logger.INFO),
    after=after_log(logger, logger.WARN),
)
async def init() -> None:
    try:
        async with async_engine.connect() as conn:
            conn: AsyncConnection
            # Try to create session to check if DB is awake
            try:
                result = await conn.execute(text("SELECT 1"))
                logger.info(f'backend_pre_start: {result.scalars().all()} SUCCESS')
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
