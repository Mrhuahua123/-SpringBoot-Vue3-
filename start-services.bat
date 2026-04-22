@echo off
echo ========================================
echo 校园阅读项目启动脚本
echo ========================================
echo.

REM 检查Java环境
echo 检查Java环境...
where java >nul 2>nul
if %errorlevel% neq 0 (
    echo 错误: Java未安装或未添加到PATH
    echo 请先安装Java 17或更高版本
    pause
    exit /b 1
)

REM 检查Maven环境
echo 检查Maven环境...
where mvn >nul 2>nul
if %errorlevel% neq 0 (
    echo 警告: Maven未安装，尝试使用现有jar文件...
)

REM 检查Node.js环境
echo 检查Node.js环境...
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo 错误: Node.js未安装或未添加到PATH
    echo 请先安装Node.js 16或更高版本
    pause
    exit /b 1
)

REM 检查npm
echo 检查npm...
where npm >nul 2>nul
if %errorlevel% neq 0 (
    echo 错误: npm未安装
    pause
    exit /b 1
)

REM 检查MySQL服务
echo 检查MySQL服务...
net start | findstr /i "mysql" >nul
if %errorlevel% neq 0 (
    echo 警告: MySQL服务未运行
    echo 请确保MySQL服务已启动
)

echo.
echo ========================================
echo 环境检查完成
echo ========================================
echo.

REM 创建必要的目录
echo 创建上传目录...
if not exist "campus-reading-backend\uploads" mkdir "campus-reading-backend\uploads"
if not exist "campus-reading-backend\uploads\avatars" mkdir "campus-reading-backend\uploads\avatars"
if not exist "campus-reading-backend\uploads\ebooks" mkdir "campus-reading-backend\uploads\ebooks"

echo.
echo ========================================
echo 启动服务
echo ========================================
echo.

REM 启动后端服务
echo 启动后端服务...
start "校园阅读后端" cmd /k "cd /d campus-reading-backend && echo 正在启动后端服务... && mvn spring-boot:run"

REM 等待后端启动
echo 等待后端启动（10秒）...
timeout /t 10 /nobreak >nul

REM 启动前端服务
echo 启动前端服务...
start "校园阅读前端" cmd /k "cd /d campus-reading-frontend && echo 正在启动前端服务... && npm run dev"

echo.
echo ========================================
echo 服务启动完成！
echo ========================================
echo.
echo 访问地址：
echo 前端：http://localhost:5173
echo 后端API：http://localhost:8080
echo.
echo 测试账户：
echo 管理员：admin / 123456
echo 普通用户：testuser / 123456
echo.
echo 按任意键退出...
pause >nul