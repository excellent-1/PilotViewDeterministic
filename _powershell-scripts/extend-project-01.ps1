# ===========================================================
#  EXPANSION SCRIPT FOR PILOTVIEW PROJECT
#  Adds: React UI (map + radar), deterministic C# suite,
#        expanded FastAPI routers, Docker Compose,
#        Documentation website.
# ===========================================================

$root = "PilotView"

#if (!(Test-Path $root)) {
#    Write-Host "PilotView folder not found. Run initial script first."
#    exit
#}

# ===========================================================
# 1. ADD REACT UI COMPONENTS
# ===========================================================

$frontend = "$root/frontend/src"

New-Item -ItemType Directory -Force -Path "$frontend/components"
New-Item -ItemType Directory -Force -Path "$frontend/hooks"
New-Item -ItemType Directory -Force -Path "$frontend/layouts"

# ---- Map Component ----
@"
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';

export default function AircraftMap({ data }) {
  if (!data) return null;

  const { lat, lon } = data.position || { lat: 0, lon: 0 };

  return (
    <MapContainer center={[lat, lon]} zoom={7} style={{ height: '400px', width: '100%' }}>
      <TileLayer url='https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'/>
      <Marker position={[lat, lon]}>
        <Popup>Aircraft Position</Popup>
      </Marker>
    </MapContainer>
  );
}
"@ | Set-Content "$frontend/components/AircraftMap.tsx"

# ---- Radar Component ----
@"
import { PolarGrid, Radar, RadarChart, PolarAngleAxis, PolarRadiusAxis } from 'recharts';

export default function ThreatRadar({ threats }) {
  if (!threats) return null;

  return (
    <RadarChart cx='50%' cy='50%' outerRadius='80%' width={500} height={300} data={threats}>
      <PolarGrid />
      <PolarAngleAxis dataKey='direction' />
      <PolarRadiusAxis />
      <Radar name='Threats' dataKey='distance' stroke='#FF4136' fill='#FF4136' fillOpacity={0.6}/>
    </RadarChart>
  );
}
"@ | Set-Content "$frontend/components/ThreatRadar.tsx"

# ---- Updated Dashboard Layout ----
@"
import { useEffect, useState } from 'react';
import AircraftMap from './components/AircraftMap';
import ThreatRadar from './components/ThreatRadar';

export default function Dashboard() {
  const [data, setData] = useState(null);

  useEffect(() => {
    const ws = new WebSocket('ws://localhost:8000/ws/live');
    ws.onmessage = msg => setData(JSON.parse(msg.data));
  }, []);

  return (
    <div style={{ padding: 20 }}>
      <h1>F-35 PilotView Dashboard</h1>
      <AircraftMap data={data} />
      <ThreatRadar threats={data?.threats || []} />
    </div>
  );
}
"@ | Set-Content "$frontend/Dashboard.tsx"


# ===========================================================
# 2. ADD FULL C# DETERMINISTIC SIMULATION SUITE
# ===========================================================

$sim = "$root/simulation-engine/src"
New-Item -ItemType Directory -Force -Path "$sim/systems"

# ---- Deterministic RNG and Systems ----
@"
using System;

public class DeterministicRng {
    private Random rng;
    public DeterministicRng(int seed) {
        rng = new Random(seed);
    }
    public double NextDouble(double min, double max) {
        return min + rng.NextDouble() * (max - min);
    }
}
"@ | Set-Content "$sim/systems/DeterministicRng.cs"

@"
public class EngineSystem {
    private DeterministicRng rng;
    public EngineSystem(DeterministicRng r) { rng = r; }

    public object GetData() {
        return new {
            temperature = rng.NextDouble(650, 750),
            rpm = rng.NextDouble(7000, 9000)
        };
    }
}
"@ | Set-Content "$sim/systems/EngineSystem.cs"

@"
public class ThreatSystem {
    private DeterministicRng rng;
    public ThreatSystem(DeterministicRng r) { rng = r; }

    public object[] GenerateThreats(int count) {
        var threats = new object[count];
        for (int i = 0; i < count; i++) {
            threats[i] = new {
                direction = rng.NextDouble(0, 360),
                distance = rng.NextDouble(1, 50)
            };
        }
        return threats;
    }
}
"@ | Set-Content "$sim/systems/ThreatSystem.cs"

# ---- Updated Simulator Main ----
@"
using StackExchange.Redis;
using System.Text.Json;
using System.Threading;

class Simulator {
    static void Main() {
        var redis = ConnectionMultiplexer.Connect("localhost:6379");
        var pub = redis.GetSubscriber();
        var db = redis.GetDatabase();

        var rng = new DeterministicRng(12345);
        var engine = new EngineSystem(rng);
        var threats = new ThreatSystem(rng);

        while (true) {
            var packet = new {
                position = new { lat = 33.64, lon = -84.42 },
                engine = engine.GetData(),
                threats = threats.GenerateThreats(10)
            };

            string json = JsonSerializer.Serialize(packet);
            db.HashSet("f35:state", new HashEntry[] { new HashEntry("latest", json) });
            pub.Publish("f35:realtime", json);

            Thread.Sleep(100); // 10 Hz update rate
        }
    }
}
"@ | Set-Content "$sim/Program.cs"


# ===========================================================
# 3. ADD FULL FASTAPI ROUTER ARCHITECTURE
# ===========================================================

$backend = "$root/backend-fastapi/app"

New-Item -ItemType Directory -Force -Path "$backend/routes"
New-Item -ItemType Directory -Force -Path "$backend/services"

# ---- Routers ----
@"
from fastapi import APIRouter
from ..services.state_service import get_current_state

router = APIRouter()

@router.get('/current')
def state():
    return get_current_state()
"@ | Set-Content "$backend/routes/state.py"

# ---- Services ----
@"
import redis
r = redis.Redis(host='localhost', port=6379, decode_responses=True)

def get_current_state():
    return r.hgetall('f35:state')
"@ | Set-Content "$backend/services/state_service.py"

# ---- Update main.py ----
@"
from fastapi import FastAPI
from fastapi.websockets import WebSocket
import redis
from app.routes.state import router as StateRouter

app = FastAPI()
app.include_router(StateRouter, prefix='/state')

r = redis.Redis(host='localhost', port=6379, decode_responses=True)

@app.websocket('/ws/live')
async def ws_live(ws: WebSocket):
    await ws.accept()
    pubsub = r.pubsub()
    pubsub.subscribe('f35:realtime')

    for msg in pubsub.listen():
        if msg['type'] == 'message':
            await ws.send_text(msg['data'])
"@ | Set-Content "$backend/main.py"


# ===========================================================
# 4. DOCKER COMPOSE (FULL STACK)
# ===========================================================

@"
version: '3.9'

services:

  redis:
    image: redis:latest
    container_name: pilotview_redis
    ports:
      - '6379:6379'

  backend:
    build: ./backend-fastapi
    container_name: pilotview_backend
    ports:
      - '8000:8000'
    depends_on:
      - redis

  simulator:
    build: ./simulation-engine
    container_name: pilotview_simulator
    depends_on:
      - redis

  frontend:
    build: ./frontend
    container_name: pilotview_frontend
    ports:
      - '3000:3000'
    depends_on:
      - backend
"@ | Set-Content "$root/docker-compose.yml"


# ===========================================================
# 5. ADD DOCUMENTATION WEBSITE (MKDocs-ready)
# ===========================================================

$docs = "$root/docs"
New-Item -ItemType Directory -Force -Path $docs

@"
site_name: PilotView Documentation
nav:
  - Home: index.md
  - Architecture: architecture.md
  - API: api.md
  - Simulation: simulation.md
  - Frontend: frontend.md
"@ | Set-Content "$root/mkdocs.yml"

@"
# PilotView Documentation

Welcome to the official documentation for the fictional F‑35 PilotView Dashboard.
"@ | Set-Content "$docs/index.md"

@"
# Architecture
High-level description of real-time and request-based flow.
"@ | Set-Content "$docs/architecture.md"

@"
# API Endpoints
/state/current  
/ws/live  
"@ | Set-Content "$docs/api.md"

@"
# Simulation Engine
Deterministic C# simulator using seeded RNG.
"@ | Set-Content "$docs/simulation.md"

@"
# Frontend System
React with map, radar, and WebSocket streaming.
"@ | Set-Content "$docs/frontend.md"


Write-Host "PilotView Expansion Complete!"
