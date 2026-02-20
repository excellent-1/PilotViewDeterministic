import { useEffect, useState } from 'react';
import AircraftMap from './components/AircraftMap.tsx';
import ThreatRadar from './components/ThreatRadar.tsx';

export default function Dashboard() {
  const [data, setData] = useState<any>(null);

  useEffect(() => {
    const ws = new WebSocket('ws://localhost:8000/ws/live');
    ws.onmessage = msg => setData(JSON.parse(msg.data) as any);
    return () => ws.close();
  }, []);

  return (
    <div style={{ padding: 20 }}>
      <h1>F-35 PilotView Dashboard</h1>
      <AircraftMap data={data} />
      <ThreatRadar threats={data?.threats || []} />
    </div>
  );
}
