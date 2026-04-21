# 测试校园阅读系统API

Write-Host "=== 校园阅读系统API测试 ===" -ForegroundColor Cyan
Write-Host "测试时间: $(Get-Date)" -ForegroundColor Gray
Write-Host ""

# 1. 测试登录API
Write-Host "1. 测试登录API..." -ForegroundColor Yellow
try {
    $loginBody = @{
        username = "admin"
        password = "admin123"
    } | ConvertTo-Json
    
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/user/login" `
        -Method Post `
        -Headers @{"Content-Type" = "application/json"} `
        -Body $loginBody `
        -ErrorAction Stop
    
    Write-Host "   登录响应: " -NoNewline
    Write-Host "成功" -ForegroundColor Green
    Write-Host "   响应数据: $($loginResponse | ConvertTo-Json -Compress)" -ForegroundColor Gray
} catch {
    Write-Host "   登录响应: " -NoNewline
    Write-Host "失败" -ForegroundColor Red
    Write-Host "   错误信息: $($_.Exception.Message)" -ForegroundColor Red
    
    # 尝试获取更多错误信息
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $errorBody = $reader.ReadToEnd()
        Write-Host "   响应内容: $errorBody" -ForegroundColor Red
    }
}

Write-Host ""

# 2. 测试注册API
Write-Host "2. 测试注册API..." -ForegroundColor Yellow
try {
    $registerBody = @{
        username = "testuser_$(Get-Random -Minimum 1000 -Maximum 9999)"
        nickname = "测试用户"
        email = "test_$(Get-Random -Minimum 1000 -Maximum 9999)@example.com"
        password = "test123"
    } | ConvertTo-Json
    
    $registerResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/user/register" `
        -Method Post `
        -Headers @{"Content-Type" = "application/json"} `
        -Body $registerBody `
        -ErrorAction Stop
    
    Write-Host "   注册响应: " -NoNewline
    Write-Host "成功" -ForegroundColor Green
    Write-Host "   响应数据: $($registerResponse | ConvertTo-Json -Compress)" -ForegroundColor Gray
} catch {
    Write-Host "   注册响应: " -NoNewline
    Write-Host "失败" -ForegroundColor Red
    Write-Host "   错误信息: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# 3. 测试健康检查
Write-Host "3. 测试健康检查..." -ForegroundColor Yellow
try {
    $healthResponse = Invoke-RestMethod -Uri "http://localhost:8080/actuator/health" `
        -Method Get `
        -ErrorAction Stop
    
    Write-Host "   健康检查: " -NoNewline
    Write-Host "成功" -ForegroundColor Green
    Write-Host "   状态: $($healthResponse.status)" -ForegroundColor Gray
} catch {
    Write-Host "   健康检查: " -NoNewline
    Write-Host "失败或未启用" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== 测试完成 ===" -ForegroundColor Cyan