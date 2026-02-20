import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
// @ts-ignore: Cannot find module './index.css' or its corresponding type declarations.
import './index.css'
import App from './App.js'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
