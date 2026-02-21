import json
import os
import requests
import time
import websocket

# ================================
# USER CONFIGURATION
# ================================

UPSTASH_REDIS_REST_URL = "https://normal-akita-5674.upstash.io"       # ends with /hgetall
UPSTASH_REDIS_REST_TOKEN = "ARYqAAImcDFhZDIzN2JmOGRiMGE0M2EzYjc1ZjFjN2UxNTMwN2YxYnAxNTY3NA"   # Bearer token

BACKEND_URL = "https://pilotviewdeterministic.onrender.com"
FRONTEND_URL = "https://pilot-view-deterministic.vercel.app"
WS_URL = "wss://pilotviewdeterministic.onrender.com/ws/live"

GITHUB_REPO = "excellent-1/PilotViewDeterministic"


print("==========================================")
print(" 🚀 PILOTVIEW CLOUD TEST SUITE — PYTHON")
print("==========================================")

# ================================
# TEST 1 — UPSTASH REDIS TEST
# ================================

def test_redis():
    print("\n[1] Testing Upstash Redis...")

    headers = {"Authorization": f"Bearer {UPSTASH_REDIS_REST_TOKEN}"}
    redis_url = f"{UPSTASH_REDIS_REST_URL}/f35:state"

    try:
        r = requests.get(redis_url, headers=headers)
        print("Redis Response:", r.text)

        if r.text.strip() == "" or r.text.strip() == "{}":
            print("❌ Redis empty or not returning state")
            return False

        print("✔ Redis OK — telemetry exists")
        return True
    except Exception as e:
        print("❌ Redis test failed:", e)
        return False


# ================================
# TEST 2 — BACKEND REST API TEST
# ================================

def test_backend_http():
    print("\n[2] Testing Backend HTTP...")

    try:
        url = BACKEND_URL + "/state/current"
        r = requests.get(url)

        print("Backend /state/current:", r.text)

        if r.status_code == 200 and r.text.strip() != "{}":
            print("✔ Backend HTTP OK")
            return True
        else:
            print("❌ Backend returned no telemetry or empty JSON")
            return False
    except Exception as e:
        print("❌ Backend unreachable:", e)
        return False


# ================================
# TEST 3 — BACKEND WEBSOCKET TEST
# ================================

def test_backend_websocket():
    print("\n[3] Testing Backend WebSocket...")

    try:
        ws = websocket.create_connection(WS_URL, timeout=10)
        message = ws.recv()
        ws.close()

        print("WebSocket message:", message)

        if len(message) > 0:
            print("✔ WebSocket streaming OK")
            return True
        else:
            print("❌ WebSocket returned empty message")
            return False
    except Exception as e:
        print("❌ WebSocket test failed:", e)
        return False


# ================================
# TEST 4 — FRONTEND TEST
# ================================

def test_frontend():
    print("\n[4] Testing Frontend (Vercel)...")

    try:
        r = requests.get(FRONTEND_URL)
        if r.status_code == 200:
            print("✔ Frontend reachable")
            return True
        else:
            print(f"❌ Frontend returned status {r.status_code}")
            return False
    except Exception as e:
        print("❌ Frontend unreachable:", e)
        return False


# ================================
# TEST 5 — GITHUB ACTIONS SIMULATOR
# ================================

def test_github_actions():
    print("\n[5] Testing GitHub Actions Simulator...")

    try:
        url = f"https://api.github.com/repos/{GITHUB_REPO}/actions/runs"
        r = requests.get(url)

        data = r.json()
        latest = data["workflow_runs"][0]

        print("Latest Run:")
        print("Status:", latest["status"])
        print("Conclusion:", latest["conclusion"])
        print("Event:", latest["event"])

        if latest["conclusion"] == "success":
            print("✔ Simulator workflow OK")
            return True
        else:
            print("❌ Simulator last run FAILED or never ran")
            return False
    except Exception as e:
        print("❌ Could not fetch GitHub Actions:", e)
        return False


# ================================
# RUN ALL TESTS
# ================================

results = {
    "Redis": test_redis(),
    "Backend HTTP": test_backend_http(),
    "Backend WebSocket": test_backend_websocket(),
    "Frontend": test_frontend(),
    "GitHub Actions Simulator": test_github_actions(),
}

print("\n==========================================")
print(" 🔍 PILOTVIEW TEST RESULTS")
print("==========================================")

for k, v in results.items():
    print(f"{k}: {'✔ PASS' if v else '❌ FAIL'}")

# Health Score
score = sum(1 for v in results.values() if v)
print(f"\nSystem Health Score: {score}/5")

if score == 5:
    print("🎉 ALL SYSTEMS GO — PilotView is fully operational!")
elif score >= 3:
    print("⚠ Some components failing — partial operation")
else:
    print("❌ Major system failure — simulator/redis/backend not talking")


print("==========================================")
print(" 🏁 TEST SUITE COMPLETE")
print("==========================================")