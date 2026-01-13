# 在Android Studio中打开StepCounter项目
# 此脚本会自动启动Android Studio并打开项目

$androidStudioPath = "D:\Program Files\Android\Android Studio\bin\studio64.exe"
$projectPath = "E:\work\SVN\stepcount"

Write-Host "=====================================" -ForegroundColor Green
Write-Host "  启动Android Studio" -ForegroundColor Green  
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""
Write-Host "项目路径: $projectPath" -ForegroundColor Yellow
Write-Host "Android Studio: $androidStudioPath" -ForegroundColor Yellow
Write-Host ""
Write-Host "正在启动Android Studio..." -ForegroundColor Cyan
Write-Host ""
Write-Host "提示:" -ForegroundColor White
Write-Host "1. 等待Gradle同步完成(首次可能需要5-10分钟)" -ForegroundColor Gray
Write-Host "2. 顶部选择设备: ANYX024511000309" -ForegroundColor Gray
Write-Host "3. 点击绿色运行按钮 ▶" -ForegroundColor Gray
Write-Host ""

# 启动Android Studio并打开项目
Start-Process -FilePath $androidStudioPath -ArgumentList $projectPath

Write-Host "✅ Android Studio已启动!" -ForegroundColor Green
Write-Host ""
Write-Host "详细步骤请参考: ANDROID_STUDIO_GUIDE.md" -ForegroundColor Cyan
