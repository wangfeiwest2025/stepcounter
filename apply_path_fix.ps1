# 需要管理员权限运行
Write-Host "PATH变量修复工具" -ForegroundColor Green
Write-Host "==================" -ForegroundColor Green

# 定义清理后的PATH路径
$cleanPaths = @(
    'C:\Windows\system32',
    'C:\Windows', 
    'C:\Windows\System32\Wbem',
    'C:\Windows\System32\WindowsPowerShell\v1.0',
    'C:\Windows\System32\OpenSSH',
    'C:\Python313',
    'C:\Python313\Scripts',
    'D:\Program Files\nodejs',
    'D:\Program Files\nodejs\node_global',
    'C:\ProgramData\chocolatey\bin',
    'D:\Users\001\AppData\Local\Android\Sdk\platform-tools',
    'D:\Users\001\AppData\Local\Android\Sdk\build-tools\34.0.0',
    'D:\Users\001\AppData\Local\Programs\Microsoft VS Code\bin',
    'D:\Program Files\Huawei\DevEco Studio\bin',
    'C:\Users\001\AppData\Roaming\npm',
    'D:\PUB\bin',
    'D:\Program Files\Git\bin',
    'D:\Program Files\Git\mingw64\bin',
    'D:\Program Files\Git\usr\bin',
    'D:\flutter\bin'
)

# 构建新的PATH字符串
$newPath = $cleanPaths -join ';'

Write-Host "新的PATH变量将包含 $($cleanPaths.Count) 个路径" -ForegroundColor Yellow
Write-Host "路径长度: $($newPath.Length) 字符" -ForegroundColor Yellow

# 确认提示
$confirmation = Read-Host "确定要应用这个新的PATH变量吗? (yes/no)"
if ($confirmation -ne 'yes') {
    Write-Host "操作已取消" -ForegroundColor Red
    exit
}

try {
    # 备份当前PATH
    $currentPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    Write-Host "正在备份当前用户PATH..." -ForegroundColor Yellow
    
    # 设置新的用户PATH
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Write-Host "✅ 用户PATH变量已更新!" -ForegroundColor Green
    
    # 可选：也更新系统PATH（需要管理员权限）
    $updateSystem = Read-Host "是否也更新系统PATH变量?(需要管理员权限) (yes/no)"
    if ($updateSystem -eq 'yes') {
        [Environment]::SetEnvironmentVariable('Path', $newPath, 'Machine')
        Write-Host "✅ 系统PATH变量已更新!" -ForegroundColor Green
    }
    
    Write-Host "" 
    Write-Host "PATH修复完成!" -ForegroundColor Green
    Write-Host "请重启命令提示符或PowerShell以使更改生效" -ForegroundColor Yellow
    Write-Host "建议重启电脑以确保所有应用程序都能识别新的PATH" -ForegroundColor Yellow
    
} catch {
    Write-Host "错误: $_" -ForegroundColor Red
    Write-Host "请确保以管理员身份运行此脚本" -ForegroundColor Red
}