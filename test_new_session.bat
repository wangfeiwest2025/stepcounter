@echo off
echo 测试新的PATH环境
echo =================
echo.

:: 启动新的命令提示符会话来测试PATH修复
cmd /k "echo 新会话的PATH变量: && echo %PATH% && echo. && where flutter && echo. && pause"