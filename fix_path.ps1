# 定义标准的Windows PATH路径
$standardPaths = @(
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
    'D:\Users\001\AppData\Local\Android\Sdk\tools',
    'D:\Users\001\AppData\Local\Android\Sdk\build-tools\34.0.0',
    'D:\Users\001\AppData\Local\Programs\Microsoft VS Code\bin',
    'D:\Program Files\Huawei\DevEco Studio\bin',
    'C:\Users\001\AppData\Roaming\npm',
    'D:\PUB\bin',
    'D:\Program Files\Git\bin',
    'D:\Program Files\Git\mingw64\bin',
    'D:\Program Files\Git\usr\local\bin',
    'D:\Program Files\Git\usr\bin'
)

# 移除重复项并保持顺序
$uniquePaths = $standardPaths | Select-Object -Unique

# 构建新的PATH字符串
$newPath = $uniquePaths -join ';'

Write-Host '新的清理后的PATH变量:' -ForegroundColor Green
Write-Host $newPath
Write-Host ''
Write-Host "路径数量: $($uniquePaths.Count)" -ForegroundColor Yellow
Write-Host ''
Write-Host '准备应用到系统...' -ForegroundColor Cyan

# 显示每个路径的验证状态
Write-Host '路径验证:' -ForegroundColor Green
foreach ($path in $uniquePaths) {
    if (Test-Path $path) {
        Write-Host "✅ $path" -ForegroundColor Green
    } else {
        Write-Host "❌ $path (不存在)" -ForegroundColor Red
    }
}