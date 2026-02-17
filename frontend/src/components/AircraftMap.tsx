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
