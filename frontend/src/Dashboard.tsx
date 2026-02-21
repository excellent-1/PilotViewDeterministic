import { useEffect, useState } from 'react';
import AircraftMap from './components/AircraftMap';
import ThreatRadar from './components/ThreatRadar';

export default function Dashboard() {
  const [data, setData] = useState<any>(null);

  useEffect(() => {
    const wsUrl = (globalThis as any).process?.env?.REACT_APP_BACKEND_API 
    // 'ws://localhost:8000/ws/live';
    const ws = new WebSocket(wsUrl);
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
