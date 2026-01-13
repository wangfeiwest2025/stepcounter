@echo off
setlocal enabledelayedexpansion

echo PATH变量修复工具
echo ==================
echo.

:: 定义新的清理后的PATH
set "NEW_PATH=C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32\OpenSSH;C:\Python313;C:\Python313\Scripts;D:\Program Files\nodejs;D:\Program Files\nodejs\node_global;C:\ProgramData\chocolatey\bin;D:\Users\001\AppData\Local\Android\Sdk\platform-tools;D:\Users\001\AppData\Local\Android\Sdk\build-tools\34.0.0;D:\Users\001\AppData\Local\Programs\Microsoft VS Code\bin;D:\Program Files\Huawei\DevEco Studio\bin;C:\Users\001\AppData\Roaming\npm;D:\PUB\bin;D:\Program Files\Git\bin;D:\Program Files\Git\mingw64\bin;D:\Program Files\Git\usr\bin"

echo 新的PATH变量长度: %NEW_PATH:~0,50%...
echo.
echo 注意: 这个操作将替换当前用户的PATH变量
echo 建议先手动备份当前PATH变量
echo.

set /p confirm=确定要应用新的PATH变量吗? (yes/no): 
if /i "%confirm%" neq "yes" (
    echo 操作已取消
    pause
    exit /b
)

:: 使用setx命令设置用户PATH（有长度限制约1024字符）
echo 正在应用新的PATH变量...
setx PATH "%NEW_PATH%"

if %errorlevel% equ 0 (
    echo.
    echo ✅ PATH变量已成功更新!
    echo.
    echo 请重启命令提示符或电脑以使更改生效
    echo 新PATH变量将在下次登录时生效
) else (
    echo.
    echo ❌ 更新失败! 可能需要管理员权限
    echo 错误代码: %errorlevel%
)

echo.
pause