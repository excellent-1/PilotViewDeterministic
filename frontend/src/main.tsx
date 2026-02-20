import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
// @ts-ignore: allow importing CSS without type declarations
import 'leaflet/dist/leaflet.css';
// @ts-ignore: allow importing CSS without type declarations
import './index.css';
import App from './App.js'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
