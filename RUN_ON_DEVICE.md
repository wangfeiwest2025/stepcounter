# 在真机上运行Android应用

## 步骤1: 准备Android手机

### 启用开发者选项
1. 打开手机**设置**
2. 找到**关于手机**
3. 连续点击**版本号** 7次,直到提示"您已处于开发者模式"

### 启用USB调试
1. 返回设置主界面
2. 找到**开发者选项**(可能在**系统**或**更多设置**中)
3. 打开**USB调试**开关
4. 如果有**USB安装**选项,也打开它

## 步骤2: 连接手机到电脑

1. 使用USB数据线连接手机到电脑
2. 手机上会弹出**允许USB调试**的提示
3. 勾选**始终允许这台计算机进行调试**
4. 点击**允许**

## 步骤3: 验证连接

在PowerShell中运行:
```powershell
adb devices
```

应该看到类似输出:
```
List of devices attached
XXXXXXXXXX    device
```

如果显示`unauthorized`,请在手机上重新授权。

## 步骤4: 运行应用

### 方法A: 直接运行(推荐)
```powershell
. .\setup_session.ps1
flutter run
```

这会自动编译、安装并启动应用。

### 方法B: 先构建再安装
```powershell
. .\setup_session.ps1
flutter build apk --debug
adb install -r build\app\outputs\flutter-apk\app-debug.apk
```

## 常见问题

### 问题1: 找不到设备
- 检查USB线是否连接好
- 尝试更换USB接口
- 确认手机已解锁
- 重启adb: `adb kill-server` 然后 `adb start-server`

### 问题2: 设备显示offline
```powershell
adb kill-server
adb start-server
adb devices
```

### 问题3: 安装失败
- 确保手机有足够存储空间
- 检查是否已安装旧版本,先卸载: `adb uninstall com.example.stepcount`

## 应用权限

首次运行时,应用会请求**身体活动识别**权限,请允许该权限以使用计步功能。

## 热重载

运行后,您可以:
- 按 `r` 热重载
- 按 `R` 热重启
- 按 `q` 退出
- 按 `h` 查看帮助
