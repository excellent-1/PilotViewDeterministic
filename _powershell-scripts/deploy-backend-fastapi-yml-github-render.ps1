# Create directories
New-Item -ItemType Directory -Force -Path ".github\workflows"

# 1. Create workflow file (PowerShell)
@"
name: 🚀 Deploy FastAPI Backend to Render
on:
  push:
    branches: [main]
    paths:
      - 'backend-fastapi/**'        # ← ONLY these files!

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: 🚀 Trigger Render Deploy
        run: |
          curl -X POST `\`            
            -H "Content-Type: application/json" `\`
            `$`{{ secrets.RENDER_DEPLOY_HOOK }}
"@ | Out-File -FilePath ".github/workflows/backend-fastapi.yml" -Encoding UTF8

# 2. Verify creation
Write-Host "✅ Workflow created:" -ForegroundColor Green
Get-Content ".github/workflows/backend-fastapi.yml"

# 3. Show git status
Write-Host "`n📁 Git status:" -ForegroundColor Yellow
git status

Write-Host "`n🎉 READY! Now:" -ForegroundColor Cyan
Write-Host "1. Render → Copy webhook URL" -ForegroundColor White
Write-Host "2. GitHub → Settings → Secrets → RENDER_DEPLOY_HOOK" -ForegroundColor White
Write-Host "3. git add . && git commit -m 'Add backend deploy' && git push" -ForegroundColor White

# In Render Dashboard:  Before Pushing - Render Webhook Setup:
# Render → Settings → Disable Auto-deploy
# Render → Your service → Manual Deploy → Copy webhook URL
# GitHub → Repo → Settings → Secrets and variables → Actions
# New repository secret:
# Name: RENDER_DEPLOY_HOOK
# Value: https://api.render.com/webhooks/... (paste webhook)

#📈 Flow Summary:
#1. You: git push backend-fastapi/
#2. GitHub: Runs workflow (2s)
#3. Workflow: POST to Render webhook
#4. Render: Runs "cd backend-fastapi && uvicorn..." 
#5. ✅ Backend live! (simulator.yml = untouched)