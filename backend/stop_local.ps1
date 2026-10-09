# Stop only this project's local development server, never another Django app.
$expectedPython = Join-Path $PSScriptRoot '.venv\Scripts\python.exe'
$ownedProcesses = Get-CimInstance Win32_Process | Where-Object {
    $_.CommandLine -and $_.CommandLine.Contains($expectedPython) -and
    $_.CommandLine.Contains('manage.py runserver 127.0.0.1:8765 --noreload')
}
foreach ($ownedProcess in $ownedProcesses) {
    Stop-Process -Id $ownedProcess.ProcessId -ErrorAction SilentlyContinue
}
Write-Output 'Mody AI local server stopped (if running). Database unchanged.'
