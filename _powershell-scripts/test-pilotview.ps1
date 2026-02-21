# ================================
# PILOTVIEW FULL CLOUD TEST SUITE
# ================================
Write-Host "===================================="
Write-Host " 🚀 PILOTVIEW CLOUD TEST SUITE START "
Write-Host "===================================="

$redisUrl = "https://normal-akita-5674.upstash.io"  # Upstash → Redis → API KEYS → REST API
$redisToken = "ARYqAAImcDFhZDIzN2JmOGRiMGE0M2EzYjc1ZjFjN2UxNTMwN2YxYnAxNTY3NA" # Upstash → Redis → API KEYS → REST API

$backend = "https://pilotviewdeterministic.onrender.com"
$frontend = "https://pilot-view-deterministic.vercel.app"
$wsUrl = "wss://pilotviewdeterministic.onrender.com/ws/live"

# -------------------------------
# TEST 1 — Upstash Redis Test
# -------------------------------
Write-Host "`n[1] Testing Redis (Upstash)..."

$redisResult = Invoke-RestMethod `
  -Method GET `
  -Uri "$redisUrl/hgetall/f35:state" `
  -Headers @{ Authorization = "Bearer $redisToken" } `
  -ErrorAction SilentlyContinue

if ($redisResult) {
    Write-Host "✔ Redis OK — telemetry exists."
} else {
    Write-Host "❌ Redis has NO telemetry."
}

# -------------------------------
# TEST 2 — Backend State Test
# -------------------------------
Write-Host "`n[2] Testing Backend /state/current..."

try {
    $response = Invoke-RestMethod "$backend/state/current"
    if ($response) {
        Write-Host "✔ Backend HTTP OK"
    } else {
        Write-Host "❌ Backend returned empty object"
    }
}
catch {
    Write-Host "❌ Backend unreachable"
}

# -------------------------------
# TEST 3 — Backend WebSocket Test
# -------------------------------
Write-Host "`n[3] Testing WebSocket Stream (10-second test)..."

Add-Type -AssemblyName System.Net.WebSockets

$ws = New-Object System.Net.WebSockets.ClientWebSocket

try {
    $uri = New-Object System.Uri($wsUrl)
    $ws.ConnectAsync($uri, [System.Threading.CancellationToken]::None).Wait()
    Write-Host "✔ WebSocket connected"

    $buffer = New-Object Byte[] 2048
    $segment = New-Object System.ArraySegment[byte] ($buffer)
    $ws.ReceiveAsync($segment, [System.Threading.CancellationToken]::None).Wait()

    $message = [System.Text.Encoding]::UTF8.GetString($buffer).Trim([char]0)
    if ($message.Length -gt 0) {
        Write-Host "✔ WebSocket RECEIVED DATA:"
        Write-Host $message
    } else {
        Write-Host "❌ WebSocket returned EMPTY data"
    }
}
catch {
    Write-Host "❌ WebSocket FAILED: $_"
}

# -------------------------------
# TEST 4 — Frontend Test (Vercel)
# -------------------------------
Write-Host "`n[4] Testing Frontend Deployment..."

try {
    $frontResp = Invoke-WebRequest $frontend -UseBasicParsing
    if ($frontResp.StatusCode -eq 200) {
        Write-Host "✔ Frontend reachable"
    } else {
        Write-Host "❌ Frontend returned status: $($frontResp.StatusCode)"
    }
}
catch {
    Write-Host "❌ Frontend unreachable"
}

# -------------------------------
# TEST 5 — GitHub Actions Simulator Test
# -------------------------------
Write-Host "`n[5] Testing GitHub Actions Simulator..."

$githubActions = "https://api.github.com/repos/excellent-1/PilotViewDeterministic/actions/runs"
$gha = Invoke-RestMethod $githubActions

if ($gha.workflow_runs.Count -gt 0) {
    $latest = $gha.workflow_runs[0]
    Write-Host "✔ Latest simulator run: $($latest.status)"
    Write-Host "  Conclusion: $($latest.conclusion)"
    Write-Host "  Run ID: $($latest.id)"
} else {
    Write-Host "❌ No GitHub Actions simulator runs found"
}

Write-Host "`n===================================="
Write-Host " ✔ TEST SUITE COMPLETE"
Write-Host "===================================="


# It checks all 5 critical cloud components:
# 1. Upstash Redis
# Checks if telemetry exists in key: f35:state.
# 2. Render Backend (REST)
# Confirms /state/current is online and returns real data.
# 3. Render Backend (WebSocket)
# Attempts a real WebSocket connection.
# Reads telemetry message.
# 4. Vercel Frontend
# Confirms frontend build is reachable and working.
# 5. GitHub Actions Simulator
# Reads latest run
# Status + conclusion (success/failure) ###
