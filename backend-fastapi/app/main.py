from fastapi import FastAPI
from fastapi.websockets import WebSocket
import redis
from app.routes.state import router as StateRouter

app = FastAPI()
app.include_router(StateRouter, prefix='/state')

# r = redis.Redis(host='localhost', port=6379, decode_responses=True)
import os

r = redis.Redis.from_url(
    os.getenv("UPSTASH_REDIS_URL"),
    password=os.getenv("UPSTASH_REDIS_PASSWORD"),
    decode_responses=True
)

@app.websocket('/ws/live')
async def ws_live(ws: WebSocket):
    await ws.accept()
    pubsub = r.pubsub()
    pubsub.subscribe('f35:realtime')

    for msg in pubsub.listen():
        if msg['type'] == 'message':
            await ws.send_text(msg['data'])
