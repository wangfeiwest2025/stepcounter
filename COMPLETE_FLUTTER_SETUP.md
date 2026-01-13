# 完整Flutter Android开发环境配置指南

## 当前状态
- ✅ **Windows版本已构建**：StepCounter.exe (立即可用)
- ❌ **Android版本需配置**：Flutter环境未完成安装
- 🔧 **需要手动配置**：Flutter SDK和Android开发环境

## 方案一：手动Flutter安装（推荐）

### 步骤1：下载Flutter SDK

**选项A：官方下载**
1. 访问：https://flutter.dev/docs/get-started/install/windows
2. 下载Windows版本ZIP文件
3. 解压到 `C:\flutter`

**选项B：使用Git**
```bash
git clone https://gitee.com/mirrors/flutter.git -b stable C:\flutter
```

### 步骤2：配置环境变量

**添加Flutter到PATH：**
1. 右键"此电脑" → "属性"
2. 点击"高级系统设置"
3. 点击"环境变量"
4. 在"系统变量"中找到"Path"
5. 添加：`C:\flutter\bin`

**设置镜像源（国内用户）：**
```powershell
$env:PUB_HOSTED_URL="https://mirrors.cloud.tencent.com/dart-pub"
$env:FLUTTER_STORAGE_BASE_URL="https://mirrors.cloud.tencent.com 步骤3：/flutter"
```

###验证安装

```bash
# 重启命令提示符，然后运行：
flutter --version
flutter doctor
```

### 步骤4：安装依赖

```bash
cd e:/work/SVN/stepcount
flutter pub get
```

### 步骤5：构建Android APK

```bash
# 构建发布版APK
flutter build apk --release

# 构建调试版APK（更快）
flutter build apk --debug
```

### 步骤6：安装到设备

```bash
# 检查连接的设备
adb devices

# 安装APK
adb install build/app/outputs/flutter-apk/app-release.apk

# 或直接运行
flutter run
```

## 方案二：使用Android Studio

### 1. 安装Android Studio
- 下载：https://developer.android.com/studio
- 安装时包含Android SDK和AVD管理器

### 2. 安装Flutter插件
- 启动Android Studio
- File → Settings → Plugins
- 搜索并安装"Flutter"插件
- 同时安装"Dart"插件

### 3. 配置Flutter SDK
- File → Settings → Languages & Frameworks → Flutter
- 设置Flutter SDK路径：`C:\flutter`

### 4. 打开项目
- File → Open → 选择项目文件夹
- Android Studio会自动检测Flutter项目

### 5. 运行应用
- 连接Android设备或启动模拟器
- 点击运行按钮（绿色三角形）

## 方案三：使用VS Code

### 1. 安装VS Code
- 下载：https://code.visualstudio.com/

### 2. 安装扩展
- 搜索并安装"Flutter"扩展
- 搜索并安装"Dart"扩展

### 3. 配置Flutter SDK
- Ctrl+Shift+P → "Flutter: Change SDK"
- 选择Flutter SDK路径

### 4. 运行应用
- F5启动调试
- 或 Ctrl+Shift+P → "Flutter: Run"

## 项目详情

### 应用信息
- **名称**：StepCounter
- **功能**：跨平台步数计数器
- **支持平台**：Android、iOS、Windows、Linux、macOS、Web

### 核心特性
1. **实时步数统计**
   - 使用设备传感器
   - 实时更新步数

2. **数据持久化**
   - 本地存储步数历史
   - 应用重启后数据不丢失

3. **统计功能**
   - 当日步数显示
   - 周统计（月统计）
   - 步数趋势图表

4. **目标管理**
   - 设置每日步数目标
   - 目标完成度显示

5. **权限管理**
   - Android活动识别权限
   - 权限请求和说明

### 技术架构
- **框架**：Flutter 3.0+
- **语言**：Dart
- **主要依赖**：
  - `pedometer: ^4.1.1` - 步数传感器
  - `shared_preferences: ^2.3.2` - 本地存储
  - `permission_handler: ^11.3.1` - 权限管理
  - `intl: ^0.19.0` - 国际化支持

### 文件结构
```
lib/
├── main.dart                 # 应用入口
├── step_counter_service.dart # 步数服务逻辑
└── step_counter_screen.dart  # 用户界面

android/
├── app/
│   ├── build.gradle         # Android构建配置
│   └── src/main/            # Android源码
├── gradle.properties        # Gradle配置
└── gradlew                  # Gradle包装器

build/
├── app/outputs/flutter-apk/ # 生成的APK文件
└── windows/                 # Windows构建文件
```

## 故障排除

### 常见问题

**1. Flutter命令不识别**
```bash
# 检查PATH配置
echo %PATH%

# 手动运行Flutter
C:\flutter\bin\flutter --version
```

**2. 网络下载失败**
```powershell
# 设置镜像源
$env:PUB_HOSTED_URL="https://mirrors.cloud.tencent.com/dart-pub"
$env:FLUTTER_STORAGE_BASE_URL="https://mirrors.cloud.tencent.com/flutter"
```

**3. Android SDK未找到**
```bash
# 设置Android SDK路径
set ANDROID_HOME=D:\Users\001\AppData\Local\Android\Sdk
set PATH=%PATH%;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\tools
```

**4. Gradle构建失败**
```bash
# 清理项目
flutter clean
flutter pub get

# 重新构建
flutter build apk
```

**5. 权限问题**
```bash
# 检查权限
adb shell pm list permissions | grep ACTIVITY_RECOGNITION

# 手动授予权限
adb shell pm grant package_name android.permission.ACTIVITY_RECOGNITION
```

### 性能优化

**1. 启用热重载**
```bash
flutter run --hot
```

**2. 构建优化**
```bash
# 使用生产模式构建
flutter build apk --release --obfuscate --split-debug-info=build/

# 分析包大小
flutter build apk --analyze-size
```

## 当前可用的解决方案

### 立即体验Windows版本
```bash
build/windows/x64/runner/Release/StepCounter.exe
```
- ✅ 功能完整
- ✅ 立即可用
- ❌ 仅限Windows平台

### 完整Android体验
按照上述指南配置Flutter环境后：
```bash
flutter run
```
- ✅ 跨平台兼容
- ✅ 原生性能
- 🔧 需要环境配置

## 下一步行动

1. **选择安装方式**：手动安装、Android Studio或VS Code
2. **配置Flutter环境**：按步骤执行安装和配置
3. **测试应用**：运行flutter doctor检查环境
4. **构建APK**：生成Android安装包
5. **安装测试**：在Android设备上测试应用

选择适合您的开发方式，完成Flutter环境配置后即可运行完整的跨平台步数计数应用。