# StepCounter Android版本安装运行指南

## 快速解决方案

由于当前环境限制（网络连接问题和Flutter未配置），无法直接构建Android APK。以下是完整的手动解决方案：

## 方法一：使用现有Windows版本（推荐）

当前可立即运行：
```bash
build/windows/x64/runner/Release/StepCounter.exe
```

## 方法二：完整Android环境配置

### 1. 安装Flutter SDK

**下载方式A：Git克隆（推荐）**
```bash
git clone https://gitee.com/mirrors/flutter.git -b stable
```

**下载方式B：压缩包下载**
从官网下载：https://flutter.dev/docs/get-started/install/windows

### 2. 配置环境变量

**添加Flutter到PATH：**
```powershell
$env:Path += ";D:\flutter\bin"
```

**设置Android镜像（中国用户）：**
```powershell
$env:PUB_HOSTED_URL="https://mirrors.cloud.tencent.com/dart-pub"
$env:FLUTTER_STORAGE_BASE_URL="https://mirrors.cloud.tencent.com/flutter"
```

### 3. 验证安装

```bash
flutter doctor
```

### 4. 配置Android开发环境

确保以下工具在PATH中：
- Android SDK
- Android SDK Platform-Tools
- Android SDK Build-Tools

### 5. 构建Android APK

```bash
# 进入项目目录
cd e:/work/SVN/stepcount

# 获取依赖
flutter pub get

# 构建发布版APK
flutter build apk --release

# 构建调试版APK（更快）
flutter build apk --debug
```

### 6. 安装到Android设备

**使用ADB安装：**
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

**或直接运行：**
```bash
flutter run
```

## 方法三：使用Android Studio（推荐）

### 1. 安装Android Studio
- 下载地址：https://developer.android.com/studio
- 安装Flutter和Dart插件

### 2. 打开项目
- File → Open → 选择项目文件夹
- Android Studio会自动检测Flutter项目

### 3. 运行应用
- 连接Android设备或启动模拟器
- 点击运行按钮（绿色三角）

## 项目信息

**应用名称：** StepCounter
**功能：** 步数计数器
**主要特性：**
- 实时步数统计
- 每日/周/月统计
- 步数目标设定
- 数据本地存储
- 权限管理

**技术栈：**
- Flutter 3.0+
- Dart语言
- Android原生开发

**关键依赖：**
- `pedometer: ^4.1.1` - 步数传感器
- `shared_preferences: ^2.3.2` - 本地存储
- `permission_handler: ^11.3.1` - 权限管理

## 权限说明

Android应用需要以下权限：
- `ACTIVITY_RECOGNITION` - 访问步数传感器
- 在Android 10+需要运行时权限申请

## 故障排除

### 网络问题
使用国内镜像源：
```bash
set PUB_HOSTED_URL=https://mirrors.cloud.tencent.com/dart-pub
set FLUTTER_STORAGE_BASE_URL=https://mirrors.cloud.tencent.com/flutter
```

### Gradle问题
```bash
flutter clean
flutter pub get
```

### 权限问题
确保在Android设备上授予活动识别权限

## 当前状态

- ✅ Windows版本已构建完成
- ❌ Android版本需要Flutter环境
- 🔧 需要手动配置开发环境

选择适合您的方法配置Android开发环境。