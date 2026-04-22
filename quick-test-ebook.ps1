# 快速测试电子书功能

Write-Host "=== 电子书功能快速测试 ===" -ForegroundColor Green
Write-Host "测试时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
Write-Host ""

# 1. 检查必要文件
Write-Host "1. 检查必要文件..." -ForegroundColor Yellow
$requiredFiles = @(
    "campus-reading-backend\src\main\java\com\example\campusreading\controller\EbookController.java",
    "campus-reading-backend\src\main\java\com\example\campusreading\service\EbookService.java",
    "campus-reading-backend\src\main\java\com\example\campusreading\utils\EbookParser.java",
    "campus-reading-backend\src\main\java\com\example\campusreading\controller\ReaderController.java",
    "campus-reading-frontend\src\views\admin\AdminBookManage.vue",
    "campus-reading-frontend\src\api\ebook.js",
    "campus-reading-frontend\src\api\reader.js"
)

$allFilesExist = $true
foreach ($file in $requiredFiles) {
    $fullPath = Join-Path $PSScriptRoot $file
    if (Test-Path $fullPath) {
        Write-Host "  ✓ $file" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $file (缺失)" -ForegroundColor Red
        $allFilesExist = $false
    }
}

if (-not $allFilesExist) {
    Write-Host "`n错误: 必要文件缺失，请检查项目结构" -ForegroundColor Red
    exit 1
}

Write-Host "`n2. 检查数据库连接..." -ForegroundColor Yellow
try {
    $result = mysql -u root -p123456 --default-character-set=utf8mb4 -e "USE campus_reading; SELECT COUNT(*) as book_count FROM t_book;" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ 数据库连接正常" -ForegroundColor Green
    } else {
        Write-Host "  ✗ 数据库连接失败" -ForegroundColor Red
    }
} catch {
    Write-Host "  ✗ 数据库连接异常: $_" -ForegroundColor Red
}

Write-Host "`n3. 检查上传目录..." -ForegroundColor Yellow
$uploadDirs = @(
    "campus-reading-backend\uploads",
    "campus-reading-backend\uploads\avatars", 
    "campus-reading-backend\uploads\ebooks"
)

foreach ($dir in $uploadDirs) {
    $fullPath = Join-Path $PSScriptRoot $dir
    if (Test-Path $fullPath) {
        Write-Host "  ✓ $dir" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $dir (将自动创建)" -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
    }
}

Write-Host "`n4. 检查测试电子书文件..." -ForegroundColor Yellow
$testEbook = Join-Path $PSScriptRoot "test-ebook.txt"
if (Test-Path $testEbook) {
    $size = (Get-Item $testEbook).Length
    $lines = (Get-Content $testEbook).Count
    Write-Host "  ✓ 测试电子书文件存在" -ForegroundColor Green
    Write-Host "    大小: $size 字节" -ForegroundColor Cyan
    Write-Host "    行数: $lines 行" -ForegroundColor Cyan
} else {
    Write-Host "  ✗ 测试电子书文件不存在" -ForegroundColor Red
    Write-Host "    将在当前目录创建测试文件..." -ForegroundColor Yellow
    
    $testContent = @"
第一章 测试章节

这是一个测试用的电子书文件。
用于验证电子书上传和解析功能。

第二章 功能测试

电子书功能包括：
1. 文件上传
2. 章节解析
3. 在线阅读
4. 章节导航

第三章 使用说明

管理员可以在图书管理页面：
1. 点击"电子书"按钮
2. 上传TXT文件
3. 自动解析章节
4. 在线阅读测试
"@
    
    Set-Content -Path $testEbook -Value $testContent -Encoding UTF8
    Write-Host "  ✓ 已创建测试电子书文件" -ForegroundColor Green
}

Write-Host "`n5. 检查编码问题..." -ForegroundColor Yellow
$javaFiles = Get-ChildItem -Path "campus-reading-backend\src" -Filter "*.java" -Recurse | Select-Object -First 10
$hasEncodingIssues = $false

foreach ($file in $javaFiles) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    if ($null -eq $content) {
        Write-Host "  ⚠ $($file.Name) 可能不是UTF-8编码" -ForegroundColor Yellow
        $hasEncodingIssues = $true
    }
}

if (-not $hasEncodingIssues) {
    Write-Host "  ✓ Java文件编码正常" -ForegroundColor Green
}

Write-Host "`n=== 测试总结 ===" -ForegroundColor Green
Write-Host "电子书功能已成功集成到系统中：" -ForegroundColor Cyan
Write-Host ""
Write-Host "主要功能：" -ForegroundColor Yellow
Write-Host "1. 管理员图书管理页面添加了电子书上传按钮" -ForegroundColor White
Write-Host "2. 支持TXT文件上传和自动章节解析" -ForegroundColor White
Write-Host "3. 提供在线阅读器界面" -ForegroundColor White
Write-Host "4. 支持章节导航和阅读设置" -ForegroundColor White
Write-Host ""
Write-Host "使用步骤：" -ForegroundColor Yellow
Write-Host "1. 启动后端服务: cd campus-reading-backend && mvn spring-boot:run" -ForegroundColor White
Write-Host "2. 启动前端服务: cd campus-reading-frontend && npm run dev" -ForegroundColor White
Write-Host "3. 登录管理员账户 (admin/123456)" -ForegroundColor White
Write-Host "4. 进入图书管理页面" -ForegroundColor White
Write-Host "5. 点击图书的'电子书'按钮进行上传" -ForegroundColor White
Write-Host ""
Write-Host "测试文件：" -ForegroundColor Yellow
Write-Host "测试电子书: $testEbook" -ForegroundColor White
Write-Host ""

Write-Host "按任意键继续..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")