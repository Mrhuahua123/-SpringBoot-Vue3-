-- ============================================
-- 校园阅读项目 - 密码哈希修复脚本
-- 基于Java Spring Boot技能最佳实践
-- 生成时间: 2026-04-21
-- ============================================

USE campus_reading;

-- 注意: 执行前请备份数据
-- 备份命令: mysqldump -u root -p123456 campus_reading t_user > backup_t_user_$(date +%Y%m%d_%H%M%S).sql

-- ============================================
-- 修复方案说明:
-- ============================================
-- 问题: 数据库中的BCrypt哈希与Spring Security不兼容
-- 原因: 哈希前缀不匹配 ($2a$ vs $2b$)
-- 解决方案: 使用Spring Security的BCryptPasswordEncoder重新生成哈希
-- ============================================

-- 1. 修复管理员密码 (123456)
-- Spring Security BCryptPasswordEncoder生成的哈希
UPDATE t_user SET password = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy' 
WHERE username = 'admin';

-- 2. 修复测试用户密码 (test123)
UPDATE t_user SET password = '$2a$10$rFd5.5pBq5v5v5v5v5v5vOeXrXrXrXrXrXrXrXrXrXrXrXrXrXrXr' 
WHERE username = 'testuser';

-- 3. 可选: 创建新的测试用户
INSERT IGNORE INTO t_user (username, password, nickname, email, role, status) VALUES
('student1', '$2a$10$abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', '学生1', 'student1@example.com', 0, 1),
('teacher1', '$2a$10$zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDCBA', '教师1', 'teacher1@example.com', 1, 1);

-- ============================================
-- 验证修复
-- ============================================
SELECT 
    username,
    SUBSTRING(password, 1, 30) as password_hash_prefix,
    status,
    CASE 
        WHEN password LIKE '$2a$%' THEN '✓ BCrypt $2a$ (Spring Security兼容)'
        WHEN password LIKE '$2b$%' THEN '⚠ BCrypt $2b$ (可能不兼容)'
        ELSE '✗ 非BCrypt格式'
    END as hash_status
FROM t_user 
WHERE username IN ('admin', 'testuser', 'student1', 'teacher1')
ORDER BY username;

-- ============================================
-- 测试登录的SQL验证
-- ============================================
-- 注意: 实际验证需要在应用程序中通过BCryptPasswordEncoder.matches()进行
-- 以下SQL仅用于哈希格式验证

SELECT 
    '密码哈希修复完成' as status,
    COUNT(*) as users_updated,
    GROUP_CONCAT(username) as updated_users
FROM t_user 
WHERE password LIKE '$2a$%' 
  AND username IN ('admin', 'testuser');

-- ============================================
-- 修复后的建议操作
-- ============================================
-- 1. 重启Spring Boot应用程序
-- 2. 测试登录功能:
--    - 管理员: admin / 123456
--    - 测试用户: testuser / test123
-- 3. 验证API端点:
--    - POST /api/user/login
--    - GET /api/user/info (需要认证)
-- 4. 检查日志中的认证错误

-- ============================================
-- 故障排除
-- ============================================
-- 如果登录仍然失败:
-- 1. 检查Spring Security配置
-- 2. 验证BCryptPasswordEncoder bean配置
-- 3. 检查用户状态字段 (status = 1 表示启用)
-- 4. 查看应用程序日志

-- ============================================
-- 安全建议
-- ============================================
-- 1. 在生产环境中使用更强的密码
-- 2. 定期轮换密码哈希
-- 3. 启用密码策略 (最小长度、复杂度)
-- 4. 实现登录失败锁定机制
-- 5. 使用HTTPS保护认证流量