# FIX STEP 1 — Install Uvicorn inside the backend-fastapi folder
cd backend-fastapi
pip install -r requirements.txt

# If requirements.txt is missing uvicorn, run:
pip install uvicorn
pip install uvicorn[standard]

# Then add it to the requirements:
pip freeze > requirements.txt