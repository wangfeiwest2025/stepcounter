# 推送通知图标更新说明

## 更新目标
使通知图标与应用图标保持视觉一致性，同时符合 Android 通知栏设计规范（白色透明剪影）。

## 解决方案
使用 Python 脚本 `generate_consistent_icon.py` 自动从应用原图标 (`ic_launcher.png`) 中提取白色主体内容，去除非透明（蓝色）背景，生成专用的通知图标 `ic_notification.png`。

### 1. 图标生成
- **源文件**: `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`
- **生成文件**: `android/app/src/main/res/drawable/ic_notification.png`
- **处理逻辑**: 提取 RGB > 200 的像素作为白色前景，其余像素设为透明。

### 2. 代码配置更新
所有通知相关的图标引用已更新为 `ic_notification`。

**文件**: `lib/background_service.dart`

**初始化**:
```dart
AndroidInitializationSettings('ic_notification')
```

**运行时通知**:
```dart
AndroidNotificationDetails(
  ...
  icon: 'ic_notification',
  ...
)
```

## 验证
重新构建后的 APK 将使用该新图标。
- 通知栏图标应显示为白色步数小人（无蓝色圆形背景）。
- 下拉通知栏颜色会自动适配系统主题。

## 构建状态
正在重新编译 release 版本 APK...
