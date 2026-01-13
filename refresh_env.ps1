# 刷新环境变量的脚本
$env:Path = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine) + ";" + [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
Write-Host "Environment variables refreshed. You can now use 'opencode' command."