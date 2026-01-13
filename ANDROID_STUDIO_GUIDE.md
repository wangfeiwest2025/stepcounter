# 使用Android Studio构建和运行StepCounter

## 前提条件
✅ Android设备已连接: ANYX024511000309
✅ Flutter环境已配置 (D:\Program Files\flutter)
✅ 所有依赖已下载

## 步骤1: 打开Android Studio

1. 启动 **Android Studio**
2. 如果看到欢迎界面,点击 **Open**
3. 如果已有项目打开,选择 **File → Open**

## 步骤2: 打开项目

1. 浏览到项目目录: `E:\work\SVN\stepcount`
2. 选择整个 `stepcount` 文件夹
3. 点击 **OK**

**重要**: 选择项目根目录,不是android子目录

## 步骤3: 等待Gradle同步

Android Studio会自动开始Gradle同步:

1. 底部会显示 "Gradle Sync" 进度条
2. 可能需要5-10分钟(首次同步)
3. 如果提示安装缺失的SDK组件,点击 **Install** 或 **OK**

### 常见同步问题及解决

#### 问题A: "Gradle version too old"
- 点击提示中的 **Update Gradle**
- 或手动修改 `android/gradle/wrapper/gradle-wrapper.properties`

#### 问题B: "Kotlin plugin version mismatch"  
- 点击 **Fix** 或 **Update**
- Android Studio会自动调整版本

#### 问题C: "SDK not found"
- File → Project Structure → SDK Location
- 设置为: `D:\Users\001\AppData\Local\Android\Sdk`

## 步骤4: 配置运行设备

1. 顶部工具栏找到设备选择器
2. 应该能看到您的设备: **ANYX024511000309**
3. 如果没有,点击下拉菜单 → **Troubleshoot Device Connections**

## 步骤5: 运行应用

### 方法A: 使用运行按钮(推荐)
1. 点击顶部工具栏的绿色 **▶ Run** 按钮
2. 或按快捷键 **Shift + F10**

### 方法B: 使用菜单
1. **Run → Run 'main.dart'**
2. 选择您的设备

### 方法C: 右键运行
1. 在项目树中找到 `lib/main.dart`
2. 右键 → **Run 'main.dart'**

## 步骤6: 首次构建

首次构建会比较慢(5-15分钟):
- 下载Gradle依赖
- 编译Kotlin代码
- 构建Flutter引擎
- 生成APK

**进度查看**: 
- 底部 **Build** 标签页显示详细日志
- 右下角显示后台任务进度

## 步骤7: 应用安装和运行

构建成功后:
1. APK自动安装到您的设备
2. 应用自动启动
3. 手机上会弹出权限请求 → 允许 **身体活动识别**

## 步骤8: 热重载开发

应用运行后,您可以:
- 修改代码
- 点击 **⚡ Hot Reload** (或按 `Ctrl+\`)
- 更改立即生效,无需重新构建

## Android Studio优势

✅ **自动解决依赖冲突**: IDE会建议最佳版本组合
✅ **可视化错误提示**: 点击错误直接跳转到问题代码
✅ **代码补全**: Dart和Kotlin代码智能提示
✅ **调试工具**: 断点、变量查看、性能分析
✅ **设备管理**: 轻松管理多个设备和模拟器

## 如果构建失败

### 查看错误详情
1. 底部 **Build** 标签页
2. 查找红色错误信息
3. 通常会有 **Quick Fix** 链接

### 常见修复方法
```
Tools → Flutter → Flutter Clean
Build → Clean Project
Build → Rebuild Project
```

### 更新Flutter插件
1. File → Settings → Plugins
2. 搜索 "Flutter"
3. 点击 **Update** (如果有)

## 预期结果

成功后您会看到:
- ✅ 设备上StepCounter应用已安装
- ✅ 应用正在运行,显示计步界面
- ✅ Android Studio底部显示 "App is running"
- ✅ 可以使用热重载进行开发

## 备用方案

如果Android Studio构建仍然失败,可以尝试:

### 方案1: 在Android Studio中打开Terminal
```powershell
. ..\setup_session.ps1
flutter run
```

### 方案2: 使用Android Studio的Flutter命令
1. Tools → Flutter → Flutter Run
2. 选择您的设备

## 需要帮助?

如果遇到具体错误,请:
1. 截图错误信息
2. 查看 Build 标签页的完整日志
3. 告诉我错误的关键词,我可以帮您诊断
