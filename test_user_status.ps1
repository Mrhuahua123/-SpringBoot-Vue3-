# 测试用户状态API

Write-Host "=== 测试用户状态API ===" -ForegroundColor Cyan
Write-Host ""

# 1. 首先登录获取token
Write-Host "1. 登录获取管理员token..." -ForegroundColor Yellow
try {
    $loginBody = @{
        username = "admin"
        password = "123456"
    } | ConvertTo-Json
    
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/user/login" `
        -Method Post `
        -Headers @{"Content-Type" = "application/json"} `
        -Body $loginBody `
        -ErrorAction Stop
    
    if ($loginResponse.code -eq 200) {
        $token = $loginResponse.data.token
        Write-Host "   登录成功，token获取" -ForegroundColor Green
    } else {
        Write-Host "   登录失败: $($loginResponse.message)" -ForegroundColor Red
        exit
    }
} catch {
    Write-Host "   登录异常: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

Write-Host ""

# 2. 获取用户列表
Write-Host "2. 获取用户列表..." -ForegroundColor Yellow
try {
    $headers = @{
        "Content-Type" = "application/json"
        "Authorization" = "Bearer $token"
    }
    
    $usersResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/admin/users?page=1&size=10" `
        -Method Get `
        -Headers $headers `
        -ErrorAction Stop
    
    Write-Host "   获取成功，用户数量: $($usersResponse.data.records.Count)" -ForegroundColor Green
    
    # 显示用户状态
    Write-Host "   用户状态详情:" -ForegroundColor Cyan
    foreach ($user in $usersResponse.data.records) {
        $statusText = if ($user.status -eq 1) { "正常(1)" } else { "禁用(0)" }
        $roleText = if ($user.role -eq 1) { "管理员" } else { "普通用户" }
        Write-Host "     - $($user.username) ($($user.nickname)): 角色=$roleText, 状态=$statusText" -ForegroundColor Gray
    }
} catch {
    Write-Host "   获取用户列表失败: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# 3. 测试修改用户状态
Write-Host "3. 测试修改用户状态API..." -ForegroundColor Yellow
try {
    # 先找一个普通用户测试
    $testUser = $usersResponse.data.records | Where-Object { $_.username -eq "testuser" } | Select-Object -First 1
    
    if ($testUser) {
        Write-Host "   找到测试用户: $($testUser.username) (当前状态: $($testUser.status))" -ForegroundColor Gray
        
        # 切换状态
        $newStatus = if ($testUser.status -eq 1) { 0 } else { 1 }
        Write-Host "   尝试修改状态为: $newStatus" -ForegroundColor Gray
        
        $updateResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/admin/users/$($testUser.id)/status?status=$newStatus" `
            -Method Put `
            -Headers $headers `
            -ErrorAction Stop
        
        Write-Host "   修改响应: code=$($updateResponse.code), message=$($updateResponse.message)" -ForegroundColor Green
        
        # 再次获取验证
        Start-Sleep -Seconds 1
        $verifyResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/admin/users?page=1&size=10" `
            -Method Get `
            -Headers $headers `
            -ErrorAction Stop
        
        $updatedUser = $verifyResponse.data.records | Where-Object { $_.id -eq $testUser.id } | Select-Object -First 1
        Write-Host "   验证新状态: $($updatedUser.status) (原状态: $($testUser.status))" -ForegroundColor Green
        
        # 改回原状态
        Write-Host "   恢复原状态..." -ForegroundColor Gray
        Invoke-RestMethod -Uri "http://localhost:8080/api/admin/users/$($testUser.id)/status?status=$($testUser.status)" `
            -Method Put `
            -Headers $headers `
            -ErrorAction Stop | Out-Null
        
        Write-Host "   状态已恢复" -ForegroundColor Green
    } else {
        Write-Host "   未找到测试用户" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   修改状态失败: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== 测试完成 ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "总结:" -ForegroundColor Yellow
Write-Host "1. 数据库设计: status=0(禁用), status=1(正常)" -ForegroundColor Gray
Write-Host "2. 前端显示: 已修复为 status=1显示'正常', status=0显示'禁用'" -ForegroundColor Gray
Write-Host "3. 操作逻辑: 启用->status=1, 禁用->status=0" -ForegroundColor Gray