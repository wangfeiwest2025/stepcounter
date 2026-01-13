# 永久添加 npm 全局路径到用户环境变量
$npmGlobalPath = "D:\Program Files\nodejs\node_global"
$currentUserPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)

if ($currentUserPath -notlike "*$npmGlobalPath*") {
    $newUserPath = $currentUserPath + ";" + $npmGlobalPath
    [Environment]::SetEnvironmentVariable("Path", $newUserPath, [EnvironmentVariableTarget]::User)
    Write-Host "已添加 $npmGlobalPath 到用户 PATH 环境变量"
    Write-Host "请重启 PowerShell 或运行以下命令刷新当前会话："
    Write-Host '$env:Path += ";D:\Program Files\nodejs\node_global"'
} else {
    Write-Host "$npmGlobalPath 已经在用户 PATH 中"
}

# 刷新当前会话
$env:Path += ";$npmGlobalPath"
Write-Host "当前会话已刷新，现在可以直接使用 iflow 和 opencode 命令"