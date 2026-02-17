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
