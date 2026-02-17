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
	cd simulation-engine && dotnet run --project src/SimulationEngine.csproj

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
