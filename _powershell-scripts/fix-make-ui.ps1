# Solution 2: If frontend directory is empty or missing package.json
# You'll need to initialize a React project. Choose one of these approaches: Remove existing frontend directory if it's empty
# Option B: Vite (Modern, faster alternative)

# rm -rf frontend
# or on Windows
# rmdir /s frontend

# Create new React app with Vite
npm create vite@latest frontend -- --template react
cd frontend
npm instally
npm run dev

###################################33

# 1. Backup your existing CRA frontend From repo root:
Rename-Item frontend frontend_cra_backup

# 2. Create a fresh Vite + React project
npm create vite@latest frontend -- --template react

#This generates:
#• package.json
#• vite.config.js
#• index.html
#• tsconfig.json / jsconfig.json
#• src/main.jsx
#• src/App.jsx

#3. Copy your old source files into the new Vite project. Copy only your React source, not CRA config files.

Copy-Item frontend_cra_backup\src\* frontend\src\ -Recurse -Force
Copy-Item frontend_cra_backup\public\* frontend\public\ -Recurse -Force
#If CRA had files directly in public/ (like logo.png, manifest.json, etc.), they are safe to move.

#4. Update entry points if needed (TS vs JS)
#If your project uses TypeScript (.tsx files), convert Vite to TypeScript:

# A) Install TS
cd frontend
npm install --save-dev typescript @types/react @types/react-dom

# B) Rename Vite's entry files:
Rename-Item src/main.jsx src/main.tsx
Rename-Item src/App.jsx src/App.tsx

#C) Create tsconfig.json (if Vite didn’t already)
npx tsc --init

#5. Fix imports inside your React files. Vite requires relative imports, not CRA aliases unless you configure them.
# Check for imports like:

import Dashboard from 'src/Dashboard';
Change to:

import Dashboard from './Dashboard';
(or set path aliases later)

#6. Update index.html script tag (Vite style)
#Ensure the entry script is:

<script type="module" src="/src/main.tsx"></script>
(Not %PUBLIC_URL% like CRA)

#7. Install dependencies
npm install

#8. Run the Vite dev server
npm run dev
#You should now see your original project running under Vite.

#9. Update your Makefile (important)
Replace:

npm start
#with:

npm run dev

###You’re done.
# If you want, paste:

Get-ChildItem frontend -Force
# and I’ll verify all required Vite files are present.

#////////////////////////////
# Base project path
$projectRoot = "C:\_______PilotView\frontend\src"
$componentsPath = "$projectRoot\components"

# Ensure directories exist
if (!(Test-Path $projectRoot)) {
    New-Item -ItemType Directory -Path $projectRoot | Out-Null
}

if (!(Test-Path $componentsPath)) {
    New-Item -ItemType Directory -Path $componentsPath | Out-Null
}

# -----------------------
# Write AircraftMap.tsx
# -----------------------
$aircraftMapContent = @"
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
"@

Set-Content -Path "$componentsPath\AircraftMap.tsx" -Value $aircraftMapContent -Force


# -----------------------
# Write ThreatRadar.tsx
# -----------------------
$threatRadarContent = @"
import { PolarGrid, Radar, RadarChart, PolarAngleAxis, PolarRadiusAxis } from 'recharts';

type Threat = {
  direction: string;
  distance: number;
};

interface ThreatRadarProps {
  threats?: Threat[] | null;
}

export default function ThreatRadar({ threats }: ThreatRadarProps) {
  if (!threats) return null;

  return (
    <RadarChart cx='50%' cy='50%' outerRadius='80%' width={500} height={300} data={threats}>
      <PolarGrid />
      <PolarAngleAxis dataKey='direction' />
      <PolarRadiusAxis />
      <Radar name='Threats' dataKey='distance' stroke='#FF4136' fill='#FF4136' fillOpacity={0.6} />
    </RadarChart>
  );
}
"@

Set-Content -Path "$componentsPath\ThreatRadar.tsx" -Value $threatRadarContent -Force


# -----------------------
# Write Dashboard.tsx
# -----------------------
$dashboardContent = @"
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
"@

Set-Content -Path "$projectRoot\Dashboard.tsx" -Value $dashboardContent -Force


Write-Host "`n✔ Files successfully inserted into your Vite project!"
Write-Host "  - $componentsPath\AircraftMap.tsx"
Write-Host "  - $componentsPath\ThreatRadar.tsx"
Write-Host "  - $projectRoot\Dashboard.tsx"

#////////  Inside frontend folder /////////////////////////////////

npm install react-leaflet leaflet
npm install recharts

npm install --save-dev @types/leaflet

