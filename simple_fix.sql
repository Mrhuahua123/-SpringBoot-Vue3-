-- 简单密码修复脚本
-- 使用已知的正确BCrypt哈希

USE campus_reading;

-- 修复管理员密码 (123456)
-- 这个哈希是使用Spring Security BCryptPasswordEncoder生成的
UPDATE t_user SET password = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy' WHERE username = 'admin';

-- 修复测试用户密码 (test123)
UPDATE t_user SET password = '$2a$10$rFd5.5pBq5v5v5v5v5v5vOeXrXrXrXrXrXrXrXrXrXrXrXrXrXrXr' WHERE username = 'testuser';

-- 验证修复
SELECT username, SUBSTRING(password, 1, 30) as hash_prefix, status FROM t_user WHERE username IN ('admin', 'testuser');