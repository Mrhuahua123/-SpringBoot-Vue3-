@echo off
echo ========================================
echo 校园阅读系统 - 管理员账户修复工具
echo ========================================
echo.

REM 检查MySQL是否可用
echo [1/3] 检查MySQL连接...
mysql --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: MySQL未安装或未添加到PATH
    echo 请确保MySQL已安装并配置环境变量
    pause
    exit /b 1
)

REM 执行修复脚本
echo [2/3] 执行数据库修复...
mysql -u root -p123456 campus_reading < sql\fix_admin.sql

if %errorlevel% neq 0 (
    echo 错误: 数据库修复失败
    echo 请检查:
    echo 1. MySQL服务是否运行
    echo 2. 数据库密码是否正确 (默认: 123456)
    echo 3. campus_reading数据库是否存在
    pause
    exit /b 1
)

echo [3/3] 修复完成!
echo.
echo 管理员账户已启用:
echo 用户名: admin
echo 密码: 123456
echo 状态: 正常 (已启用)
echo.
echo 现在可以尝试登录管理员账户了。
echo.

REM 可选: 显示当前用户状态
echo 当前用户状态:
mysql -u root -p123456 campus_reading -e "SELECT username, nickname, CASE role WHEN 0 THEN '普通用户' WHEN 1 THEN '管理员' END as 角色, CASE status WHEN 0 THEN '禁用' WHEN 1 THEN '正常' END as 状态 FROM t_user ORDER BY role DESC;"

echo.
echo ========================================
echo 修复完成! 按任意键退出...
pause >nul