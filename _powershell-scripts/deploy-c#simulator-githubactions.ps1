# Create folder structure for GitHub Actions workflow
$workflowDir = ".github/workflows"
New-Item -ItemType Directory -Force -Path $workflowDir | Out-Null

# Path for the workflow file
$workflowFile = "$workflowDir/simulator.yml"

# YAML content
$yaml = @"
name: Run Simulator

on:
  schedule:
    - cron: "*/1 * * * *"  # runs every 1 minute
  workflow_dispatch:

jobs:
  run:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-dotnet@v4
        with:
          dotnet-version: 7.0.x

      - name: Install Redis Client
        run: dotnet add simulation-engine/src package StackExchange.Redis

      - name: Set Environment
        run: |
          echo "UPSTASH_REDIS_URL=\$\{{ secrets.UPSTASH_REDIS_URL }}" >> \$GITHUB_ENV
          echo "UPSTASH_REDIS_PASSWORD=\$\{{ secrets.UPSTASH_REDIS_PASSWORD }}" >> \$GITHUB_ENV

      - name: Run Simulator
        run: dotnet run --project simulation-engine/src
"@

# Write the file
Set-Content -Path $workflowFile -Value $yaml -Encoding UTF8

Write-Host "Created workflow file at $workflowFile"
Write-Host "Remember to add GitHub Secrets: UPSTASH_REDIS_URL and UPSTASH_REDIS_PASSWORD"