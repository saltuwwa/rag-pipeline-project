# Создаёт zip проекта, исключая: .git, __pycache__, .env, venv, .ipynb_checkpoints, .cursor
$projectDir = $PSScriptRoot
$parentDir = Split-Path -Parent $projectDir  
$zipName = "RAG_Pipeline_Project.zip"
$zipPath = Join-Path $parentDir $zipName
$tempDir = Join-Path $env:TEMP "rag_zip_$(Get-Random)"

$destDir = Join-Path $tempDir (Split-Path -Leaf $projectDir)
New-Item -ItemType Directory -Path $destDir -Force | Out-Null
robocopy $projectDir $destDir /E /XD .git __pycache__ venv .venv .ipynb_checkpoints .cursor /XF .env /NFL /NDL /NJH /NJS | Out-Null

# Удаляем только из корня (README.md оставляем как общий)
Get-ChildItem $destDir -File | Where-Object {
    $_.Name -in @(".gitignore", "make_zip.ps1") -or $_.Name -like "*.pdf"
} | Remove-Item -Force

Compress-Archive -Path $destDir -DestinationPath $zipPath -Force
Remove-Item $tempDir -Recurse -Force

Write-Host "Создан: $zipPath"