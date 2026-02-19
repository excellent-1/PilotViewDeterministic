import os
import redis

def get_redis():
    url = os.getenv("UPSTASH_REDIS_URL")
    if not url:
        return None
    if not (url.startswith("redis://") or url.startswith("rediss://")):
        # optional: auto-fix if someone set host:port
        url = "rediss://" + url

    return redis.Redis.from_url(
        url,
        password=os.getenv("UPSTASH_REDIS_PASSWORD"),
        decode_responses=True,
        ssl=url.startswith("rediss://"),
    )

def get_current_state():
    r = get_redis()
    return {} if r is None else r.hgetall("f35:state")