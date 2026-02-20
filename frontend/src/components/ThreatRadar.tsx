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
