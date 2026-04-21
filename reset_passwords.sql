-- 重置用户密码为 123456
USE campus_reading;

-- 管理员密码重置为 123456 (BCrypt哈希)
UPDATE t_user SET password = '$2a$10$BvFA576YTDvvxhE2zFiDQu8QLiAQBqPNCl1qmrRpbl7M6VreFN2dm' 
WHERE username = 'admin';

-- 测试用户密码重置为 123456 (BCrypt哈希)
UPDATE t_user SET password = '$2a$10$BvFA576YTDvvxhE2zFiDQu8QLiAQBqPNCl1qmrRpbl7M6VreFN2dm' 
WHERE username = 'testuser';

-- 验证
SELECT 
    username, 
    nickname,
    CASE role 
        WHEN 0 THEN '普通用户' 
        WHEN 1 THEN '管理员' 
    END as role_name,
    CASE status 
        WHEN 0 THEN '禁用' 
        WHEN 1 THEN '正常' 
    END as status_name,
    LEFT(password, 30) as password_hash
FROM t_user 
ORDER BY role DESC, id;