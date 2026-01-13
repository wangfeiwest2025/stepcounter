# Flutter完整环境配置脚本（改进版）

Write-Host "========================================" -ForegroundColor Green
Write-Host "     Flutter Android环境配置工具        " -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# 1. 创建Flutter安装目录
Write-Host "`n[1/7] 创建Flutter安装目录..." -ForegroundColor Yellow
$flutterDir = "C:\flutter"
if (!(Test-Path $flutterDir)) {
    New-Item -ItemType Directory -Path $flutterDir -Force
    Write-Host "✅ Flutter目录创建成功: $flutterDir" -ForegroundColor Green
} else {
    Write-Host "✅ Flutter目录已存在: $flutterDir" -ForegroundColor Green
}

# 2. 设置镜像环境变量
Write-Host "`n[2/7] 配置Flutter镜像源..." -ForegroundColor Yellow
$env:PUB_HOSTED_URL = "https://mirrors.cloud.tencent.com/dart-pub"
$env:FLUTTER_STORAGE_BASE_URL = "https://mirrors.cloud.tencent.com/flutter"
Write-Host "✅ 镜像源配置完成" -ForegroundColor Green

# 3. 检查现有Flutter安装
Write-Host "`n[3/7] 检查现有Flutter安装..." -ForegroundColor Yellow
$flutterBin = "$flutterDir\bin\flutter.exe"
if (Test-Path $flutterBin) {
    Write-Host "✅ 发现现有Flutter安装" -ForegroundColor Green
    
    # 添加Flutter到PATH
    $flutterPath = "C:\flutter\bin"
    $currentPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    
    if ($currentPath -notlike "*$flutterPath*") {
        $newPath = $currentPath + ";" + $flutterPath
        [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
        Write-Host "✅ PATH环境变量已更新" -ForegroundColor Green
    } else {
        Write-Host "✅ Flutter已在PATH中" -ForegroundColor Green
    }
    
    # 刷新环境变量
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + [System.Environment]::GetEnvironmentVariable("Path","Machine")
    
    try {
        $flutterVersion = & flutter --version 2>&1
        Write-Host "Flutter版本信息:" -ForegroundColor Cyan
        Write-Host $flutterVersion -ForegroundColor White
        Write-Host "✅ Flutter已可用!" -ForegroundColor Green
        
        # 跳过下载步骤
        $skipDownload = $true
    } catch {
        Write-Host "⚠️ Flutter安装不完整，需要重新下载" -ForegroundColor Yellow
        $skipDownload = $false
    }
} else {
    Write-Host "❌ 未发现Flutter安装" -ForegroundColor Yellow
    $skipDownload = $false
}

# 4. 下载Flutter SDK（如果需要）
if (-not $skipDownload) {
    Write-Host "`n[4/7] 下载Flutter SDK..." -ForegroundColor Yellow
    
    $flutterZip = "C:\flutter_windows.zip"
    
    # 尝试多个下载源
    $downloadUrls = @(
        "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.22.3-stable.zip",
        "https://mirrors.cloud.tencent.com/flutter/flutter_windows_3.22.3-stable.zip",
        "https://github.com/flutter/flutter/archive/refs/tags/3.22.3.zip"
    )
    
    $downloadSuccess = $false
    
    foreach ($url in $downloadUrls) {
        try {
            Write-Host "尝试从 $url 下载..." -ForegroundColor Cyan
            Invoke-WebRequest -Uri $url -OutFile $flutterZip -UseBasicParsing -TimeoutSec 30
            Write-Host "✅ 下载成功" -ForegroundColor Green
            $downloadSuccess = $true
            break
        } catch {
            Write-Host "⚠️ 下载失败: $_" -ForegroundColor Yellow
            continue
        }
    }
    
    if (-not $downloadSuccess) {
        Write-Host "❌ 所有下载源都失败了" -ForegroundColor Red
        Write-Host "请手动下载Flutter并解压到 C:\flutter" -ForegroundColor Yellow
        Write-Host "下载地址: https://flutter.dev/docs/get-started/install/windows" -ForegroundColor Cyan
        
        # 提示用户手动下载
        Read-Host "按回车键继续手动配置..."
        
        # 检查用户是否手动解压了Flutter
        if (Test-Path $flutterBin) {
            Write-Host "✅ 检测到手动安装的Flutter" -ForegroundColor Green
            $skipDownload = $true
        } else {
            Write-Host "❌ 未找到Flutter，请先手动下载解压" -ForegroundColor Red
            exit 1
        }
    }
}

# 5. 解压Flutter（如果需要）
if (-not $skipDownload) {
    Write-Host "`n[5/7] 解压Flutter..." -ForegroundColor Yellow
    try {
        Expand-Archive -Path $flutterZip -DestinationPath "C:\" -Force
        Write-Host "✅ Flutter解压完成" -ForegroundColor Green
        
        # 清理下载文件
        Remove-Item $flutterZip -Force
    } catch {
        Write-Host "❌ 解压失败: $_" -ForegroundColor Red
        exit 1
    }
}

# 6. 配置PATH环境变量
Write-Host "`n[6/7] 配置环境变量..." -ForegroundColor Yellow
$flutterPath = "C:\flutter\bin"

# 获取当前用户PATH
$currentPath = [Environment]::GetEnvironmentVariable('Path', 'User')

# 检查Flutter是否已在PATH中
if ($currentPath -notlike "*$flutterPath*") {
    $newPath = $currentPath + ";" + $flutterPath
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Write-Host "✅ PATH环境变量已更新" -ForegroundColor Green
} else {
    Write-Host "✅ Flutter已在PATH中" -ForegroundColor Green
}

# 7. 验证Flutter安装
Write-Host "`n[7/7] 验证Flutter安装..." -ForegroundColor Yellow

# 刷新环境变量
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + [System.Environment]::GetEnvironmentVariable("Path","Machine")

# 等待一下让环境变量生效
Start-Sleep -Seconds 3

try {
    $flutterVersion = & flutter --version 2>&1
    Write-Host "✅ Flutter安装成功!" -ForegroundColor Green
    Write-Host "Flutter版本信息:" -ForegroundColor Cyan
    Write-Host $flutterVersion -ForegroundColor White
    
    # 运行flutter doctor
    Write-Host "`n运行Flutter Doctor检查..." -ForegroundColor Yellow
    & flutter doctor
    
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "🎉 Flutter环境配置完成!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    
    # 询问是否构建APK
    Write-Host "`n是否要构建Android APK? (y/n): " -NoNewline
    $buildChoice = Read-Host
    
    if ($buildChoice -eq 'y' -or $buildChoice -eq 'Y') {
        Write-Host "`n开始构建APK..." -ForegroundColor Cyan
        
        # 设置镜像环境变量
        $env:PUB_HOSTED_URL = "https://mirrors.cloud.tencent.com/dart-pub"
        $env:FLUTTER_STORAGE_BASE_URL = "https://mirrors.cloud.tencent.com/flutter"
        
        # 获取依赖
        Write-Host "获取项目依赖..." -ForegroundColor Yellow
        & flutter pub get
        
        # 构建APK
        Write-Host "构建Android APK..." -ForegroundColor Yellow
        & flutter build apk --release
        
        # 检查构建结果
        $apkPath = "build\app\outputs\flutter-apk\app-release.apk"
        if (Test-Path $apkPath) {
            Write-Host "✅ APK构建成功: $apkPath" -ForegroundColor Green
            Write-Host "APK文件大小: $((Get-Item $apkPath).Length / 1MB | ForEach-Object { [math]::Round($_, 2) }) MB" -ForegroundColor Cyan
        } else {
            Write-Host "❌ APK构建失败" -ForegroundColor Red
        }
    }
    
} catch {
    Write-Host "❌ Flutter验证失败: $_" -ForegroundColor Red
    Write-Host "请重启命令提示符或重启电脑后再试" -ForegroundColor Yellow
}

Write-Host "`n请重启命令提示符以使用Flutter命令" -ForegroundColor Yellow