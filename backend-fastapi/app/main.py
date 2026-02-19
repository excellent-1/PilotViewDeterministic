from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
import redis
import asyncio
import os
import logging
from app.routes.state import router as StateRouter

# Logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# App
app = FastAPI(
    title="PilotView API",
    description="Real-time F-35 telemetry and state management",
    version="1.0.0"
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Change to specific domains in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routers
app.include_router(StateRouter, prefix="/state", tags=["State"])

# Redis connection
try:
    r = redis.Redis.from_url(
        os.environ["UPSTASH_REDIS_URL"],
        password=os.environ.get("UPSTASH_REDIS_PASSWORD"),
        decode_responses=True,
        ssl=True,
        socket_connect_timeout=10
    )
    # r.ping()  # Test connection
    logger.info("✅ Redis connected successfully")
except Exception as e:
    logger.error(f"❌ Redis connection failed: {r} _ {e}")
    r = None


# Root endpoint
@app.get("/")
def root():
    return {
        "status": "OK",
        "service": "PilotView API",
        "message": "Real-time F-35 telemetry system online"
    }


# Health check
@app.get("/health")
def health():
    r = redis.Redis.from_url(
        os.environ["UPSTASH_REDIS_URL"],
        password=os.environ.get("UPSTASH_REDIS_PASSWORD"),
        decode_responses=True,
        ssl=True,
        socket_connect_timeout=10
    )
    if not r:
        return {"healthy": True, "redis": "not-initialized"}

    try:
        r.get("health-check")
        logger.info("✅ /health Redis connected successfully")
        return {"healthy": True, "redis": "connected"}
    except Exception as e:
        logger.error(f"❌ /health Redis connection failed: {r} _ {e}")
        return {"healthy": True, "redis": "disconnected" }


# WebSocket for live telemetry
@app.websocket("/ws/live")
async def ws_live(websocket: WebSocket):
    await websocket.accept()
    logger.info("🔌 WebSocket client connected")
    
    if not r:
        await websocket.send_json({"error": "Redis unavailable"})
        await websocket.close()
        return

    pubsub = r.pubsub()
    pubsub.subscribe("f35:realtime")

    try:
        # Run Redis listener in a separate thread to avoid blocking
        def listen():
            for msg in pubsub.listen():
                if msg["type"] == "message":
                    return msg["data"]
            return None

        while True:
            # Check for incoming messages from client (optional)
            try:
                data = await asyncio.wait_for(websocket.receive_text(), timeout=0.1)
                logger.info(f"Received from client: {data}")
            except asyncio.TimeoutError:
                pass

            # Poll Redis in non-blocking way
            message = await asyncio.to_thread(pubsub.get_message, timeout=0.1)
            if message and message["type"] == "message":
                await websocket.send_text(message["data"])

    except WebSocketDisconnect:
        logger.info("🔌 WebSocket client disconnected")
    except Exception as e:
        logger.error(f"❌ WebSocket error: {e}")
    finally:
        pubsub.unsubscribe()
        pubsub.close()


# Startup event
@app.on_event("startup")
async def startup():
    logger.info("🚀 PilotView API starting up...")


# Shutdown event
@app.on_event("shutdown")
async def shutdown():
    logger.info("🛑 PilotView API shutting down...")
    if r:
        r.close()

"""
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
"""