import asyncio
import logging

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection
from tenacity import after_log, before_log, retry, stop_after_attempt, wait_fixed

from backend.app.db.session import async_engine

max_tries = 60 * 5  # 5 minutes
wait_seconds = 1


@retry(
    stop=stop_after_attempt(max_tries),
    wait=wait_fixed(wait_seconds),
    before=before_log(logging.getLogger(), logging.INFO),
    after=after_log(logging.getLogger(), logging.WARN),
)
async def init() -> None:
    try:
        async with async_engine.connect() as conn:
            conn: AsyncConnection
            try:
                result = await conn.execute(text("SELECT 1"))
                logging.info(f'backend_pre_start: {result.scalars().all()} SUCCESS')
            except Exception as e:
                logging.info(f'backend_pre_start: Exception: {e.args}')
                await conn.rollback()
                await conn.close()
    except Exception as e:
        logging.error(e)
        raise e


def main() -> None:
    logging.info("Initializing service")
    asyncio.run(init())
    logging.info("Service finished initializing")


if __name__ == "__main__":
    main()
