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
	cd backend-fastapi && ..\venv\Scripts\python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
api-old:
	cd backend-fastapi && uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

ui:
	cd frontend && npm install && npm run dev

# Install/Update backend dependencies
api-install:
	cd backend-fastapi && pip install -r requirements.txt

# Run API (activates venv first)
api-run:
	.\venv\Scripts\Activate.ps1 && cd backend-fastapi && uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Fresh install (use this once!)
api-fresh:
	python -m venv venv
	.\venv\Scripts\Activate.ps1 && make install

api-test:
	curl http://localhost:8000/ || echo "Start 'make api' first"
	curl http://localhost:8000/health

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
