# 密码哈希生成工具 - PowerShell版本

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "校园阅读项目 - 密码哈希修复工具" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Cyan

# 需要修复的用户
$users = @(
    @{username="admin"; password="123456"},
    @{username="testuser"; password="test123"}
)

Write-Host "`n生成新的密码哈希:" -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray

$sqlStatements = @()

foreach ($user in $users) {
    # 使用.NET的BCrypt实现
    $hashed = [BCrypt.Net.BCrypt]::HashPassword($user.password)
    
    Write-Host "用户名: $($user.username)" -ForegroundColor White
    Write-Host "密码: $($user.password)" -ForegroundColor Gray
    Write-Host "BCrypt哈希: $hashed" -ForegroundColor Yellow
    
    # 验证生成的哈希
    $isValid = [BCrypt.Net.BCrypt]::Verify($user.password, $hashed)
    if ($isValid) {
        Write-Host "验证结果: ✓ 有效" -ForegroundColor Green
    } else {
        Write-Host "验证结果: ✗ 无效" -ForegroundColor Red
    }
    
    # 生成SQL语句
    $sql = "UPDATE t_user SET password = '$hashed' WHERE username = '$($user.username)';"
    $sqlStatements += $sql
    Write-Host "SQL: $sql" -ForegroundColor Cyan
    Write-Host ""
}

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "SQL更新脚本:" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Cyan
foreach ($sql in $sqlStatements) {
    Write-Host $sql -ForegroundColor White
}

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "执行步骤:" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "1. 连接到MySQL数据库:" -ForegroundColor White
Write-Host "   mysql -u root -p123456 campus_reading" -ForegroundColor Gray

Write-Host "`n2. 执行以下SQL语句:" -ForegroundColor White
for ($i = 0; $i -lt $sqlStatements.Count; $i++) {
    Write-Host "   $($i+1). $($sqlStatements[$i])" -ForegroundColor Gray
}

Write-Host "`n3. 验证修复:" -ForegroundColor White
Write-Host "   SELECT username, password FROM t_user WHERE username IN ('admin', 'testuser');" -ForegroundColor Gray

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "注意:" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "1. 确保数据库服务正在运行" -ForegroundColor White
Write-Host "2. 执行前备份重要数据" -ForegroundColor White
Write-Host "3. 修复后测试登录功能" -ForegroundColor White

# 创建SQL文件
$sqlContent = @"
-- 校园阅读项目 - 密码修复脚本
-- 生成时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
-- 注意: 执行前请备份数据

USE campus_reading;

-- 修复管理员密码 (123456)
UPDATE t_user SET password = '$($sqlStatements[0].Split("'")[1])' WHERE username = 'admin';

-- 修复测试用户密码 (test123)
UPDATE t_user SET password = '$($sqlStatements[1].Split("'")[1])' WHERE username = 'testuser';

-- 验证修复
SELECT username, password, status FROM t_user WHERE username IN ('admin', 'testuser');
"@

$sqlContent | Out-File -FilePath "fix_passwords.sql" -Encoding UTF8
Write-Host "`n已生成SQL文件: fix_passwords.sql" -ForegroundColor Green