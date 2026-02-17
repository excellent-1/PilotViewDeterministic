import redis
#r = redis.Redis(host='localhost', port=6379, decode_responses=True)
import os

r = redis.Redis.from_url(
    os.getenv("UPSTASH_REDIS_URL"),
    password=os.getenv("UPSTASH_REDIS_PASSWORD"),
    decode_responses=True
)

def get_current_state():
    return r.hgetall('f35:state')
