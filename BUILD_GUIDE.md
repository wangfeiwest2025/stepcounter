# Android APK 构建指南

## 问题分析

当前通过命令行构建 APK 时遇到以下问题：

1. **Flutter Dart SDK 文件锁定**：Dart SDK 文件被其他进程（可能是 Android Studio）占用，无法更新
2. **Flutter 依赖解析失败**：无法从 Maven 仓库找到特定版本的 Flutter 引擎依赖
3. **Git 路径缺失**：Flutter 需要 git 来确定引擎版本，但 git 不在 PATH 中

## 解决方案

### 方法 1：使用 Android Studio 构建（推荐）

由于命令行构建遇到技术限制，建议使用 Android Studio 的图形界面来构建 APK：

1. **打开 Android Studio**
   - 项目已经通过 `open_in_android_studio.ps1` 脚本打开
   - 如果未打开，运行：`powershell -ExecutionPolicy Bypass -File open_in_android_studio.ps1`

2. **等待 Gradle 同步完成**
   - Android Studio 会自动检测 Flutter 项目
   - 首次同步可能需要 5-10 分钟
   - 查看底部的进度条

3. **选择目标设备**
   - 点击顶部工具栏的下拉菜单
   - 选择已连接的 Android 设备或启动模拟器

4. **构建 APK**
   - 点击菜单：`Build` → `Build Bundle(s) / APK(s)` → `Build APK(s)`
   - 或点击工具栏的绿色运行按钮 ▶

5. **查找生成的 APK**
   - 构建完成后，会弹出通知
   - 点击通知中的 "locate" 按钮
   - APK 文件通常位于：`build/app/outputs/flutter-apk/app-release.apk`

### 方法 2：修复 Flutter 环境（可选）

如果仍然希望通过命令行构建，需要先修复 Flutter 环境：

1. **关闭所有占用 Flutter 文件的进程**
   ```powershell
   # 关闭 Android Studio、Gradle 守护进程等
   taskkill /F /IM studio64.exe /T
   taskkill /F /IM java.exe /T
   ```

2. **重新启动电脑**
   - 确保所有进程都完全关闭

3. **重新安装 Flutter**
   ```powershell
   # 备份当前 Flutter 安装
   Move-Item "D:\Program Files\flutter" "D:\Program Files\flutter.backup"
   
   # 下载最新版本
   Invoke-WebRequest -Uri "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.38.5-stable.zip" -OutFile "D:\flutter_windows.zip"
   
   # 解压
   Expand-Archive -Path "D:\flutter_windows.zip" -DestinationPath "D:\" -Force
   ```

4. **重新配置环境**
   ```powershell
   # 运行环境设置脚本
   . .\setup_session.ps1
   
   # 验证安装
   flutter doctor
   ```

5. **重新构建**
   ```powershell
   flutter clean
   flutter pub get
   flutter build apk --release
   ```

## 当前状态

- ✅ 项目结构完整
- ✅ 依赖已下载（`flutter pub get` 成功）
- ✅ Android SDK 配置正确（版本 36）
- ✅ Gradle 配置已更新（Kotlin 2.1.0）
- ❌ Flutter Dart SDK 锁定问题
- ❌ Flutter 依赖解析问题

## 已完成的配置修改

1. **android/app/build.gradle**
   - `compileSdk` 从 34 更新到 36
   - `targetSdk` 从 34 更新到 36

2. **android/build.gradle**
   - `kotlin_version` 从 1.9.24 更新到 2.1.0

3. **android/gradle.properties**
   - 添加 `android.suppressUnsupportedCompileSdk=36`

4. **android/settings.gradle**
   - 添加 Flutter 本地仓库路径

## 推荐下一步

**使用 Android Studio 构建是最可靠的方法**，因为：
- Android Studio 会自动处理依赖冲突
- 图形界面更容易调试问题
- 可以实时查看构建日志和错误

如需帮助，请参考：
- `ANDROID_STUDIO_GUIDE.md` - Android Studio 使用指南
- `ANDROID_SETUP_GUIDE.md` - 完整环境配置指南
- `ANDROID_BUILD_STATUS.md` - 构建状态说明
