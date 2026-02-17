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
