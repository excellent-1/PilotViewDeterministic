import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';
// @ts-ignore: allow importing leaflet CSS without type declarations
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';

// Fix default marker icon in Vite
delete (L.Icon.Default.prototype as any)._getIconUrl;

L.Icon.Default.mergeOptions({
  iconRetinaUrl: new URL('leaflet/dist/images/marker-icon-2x.png', import.meta.url).toString(),
  iconUrl: new URL('leaflet/dist/images/marker-icon.png', import.meta.url).toString(),
  shadowUrl: new URL('leaflet/dist/images/marker-shadow.png', import.meta.url).toString(),
});

type AircraftMapProps = {
  data?: {
    position?: {
      lat: number;
      lon: number;
    } | null;
  } | null;
};

export default function AircraftMap({ data }: AircraftMapProps) {
  if (!data) return null;

  const { lat, lon } = data.position ?? { lat: 0, lon: 0 };

  return (
    <MapContainer center={[lat, lon]} zoom={7} style={{ height: '400px', width: '100%' }}>
      <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
      <Marker position={[lat, lon]}>
        <Popup>Aircraft Position</Popup>
      </Marker>
    </MapContainer>
  );
}
