# ============================================
# CREATE FULL PILOTVIEW PROJECT STRUCTURE
# ============================================

$root = "PilotView"
New-Item -ItemType Directory -Force -Path $root

# Backend - FastAPI
$fastapi = "$root/backend-fastapi"
New-Item -ItemType Directory -Force -Path $fastapi
New-Item -ItemType Directory -Force -Path "$fastapi/app"
New-Item -ItemType Directory -Force -Path "$fastapi/app/routes"
New-Item -ItemType Directory -Force -Path "$fastapi/app/services"

@"
from fastapi import FastAPI
import redis
from fastapi.websockets import WebSocket

app = FastAPI()
r = redis.Redis(host="localhost", port=6379, decode_responses=True)

@app.get("/state/current")
def current_state():
    return r.hgetall("f35:state")

@app.websocket("/ws/live")
async def ws_live(ws: WebSocket):
    await ws.accept()
    pubsub = r.pubsub()
    pubsub.subscribe("f35:realtime")

    for msg in pubsub.listen():
        if msg["type"] == "message":
            await ws.send_text(msg["data"])
"@ | Set-Content "$fastapi/app/main.py"

@"
fastapi
redis
uvicorn
python-dotenv
"@ | Set-Content "$fastapi/requirements.txt"

# Simulation Engine - C#
$sim = "$root/simulation-engine"
New-Item -ItemType Directory -Force -Path $sim
New-Item -ItemType Directory -Force -Path "$sim/src"

@"
using StackExchange.Redis;
using System.Text.Json;

class Simulator {
    static void Main() {
        var redis = ConnectionMultiplexer.Connect("localhost:6379");
        var pub = redis.GetSubscriber();
        var db = redis.GetDatabase();

        while(true) {
            var state = new {
                position = new { lat = 33.640,-84.427 },
                altitude = 30000,
                engineTemp = 720,
                systemHealth = "Nominal"
            };

            string json = JsonSerializer.Serialize(state);
            db.HashSet("f35:state", new HashEntry[] { new HashEntry("latest", json) });
            pub.Publish("f35:realtime", json);

            Thread.Sleep(100); // 10 Hz
        }
    }
}
"@ | Set-Content "$sim/src/Program.cs"

# Frontend - React/Typescript
$frontend = "$root/frontend"
New-Item -ItemType Directory -Force -Path $frontend

@"
import { useEffect, useState } from "react";

export default function Dashboard() {
  const [data, setData] = useState(null);

  useEffect(() => {
    const ws = new WebSocket("ws://localhost:8000/ws/live");
    ws.onmessage = msg => setData(JSON.parse(msg.data));
  }, []);

  return (
    <div>
      <h1>F‑35 PilotView Dashboard</h1>
      <pre>{JSON.stringify(data, null, 2)}</pre>
    </div>
  );
}
"@ | Set-Content "$frontend/Dashboard.tsx"

"Project created successfully."

