# ============================================
# PowerShell Script: Create Makefile for PilotView
# ============================================

$projectRoot = "_______PilotView"
$makefilePath = Join-Path $projectRoot "Makefile"

# Ensure PilotView folder exists
if (-Not (Test-Path $projectRoot)) {
    Write-Host "ERROR: PilotView folder not found in current directory."
    Write-Host "Run this script from the parent folder of PilotView."
    exit
}

$makefileContent = @"
# ============================================
# PilotView Project Makefile
# ============================================

# --------------------------------------------
# Docker Commands
# --------------------------------------------
up:
	docker-compose up --build

down:
	docker-compose down

logs:
	docker-compose logs -f

rebuild:
	docker-compose down
	docker-compose build --no-cache
	docker-compose up

# --------------------------------------------
# Manual Local Development Commands
# --------------------------------------------
sim:
	cd simulation-engine && dotnet run --project src

api:
	cd backend-fastapi && uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

ui:
	cd frontend && npm install && npm start

# --------------------------------------------
# Documentation Website Commands (mkdocs)
# --------------------------------------------
docs:
	mkdocs serve

docs-build:
	mkdocs build

# --------------------------------------------
# Utility Commands
# --------------------------------------------
clean:
	docker system prune -a -f

status:
	docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
"@

# Write Makefile to disk
Set-Content -Path $makefilePath -Value $makefileContent -Encoding UTF8

Write-Host "Makefile created successfully at $makefilePath"