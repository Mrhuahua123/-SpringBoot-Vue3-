-- 校园阅读系统 - 管理员账户修复脚本
USE campus_reading;

-- 1. 启用管理员账户（将status从0改为1）
UPDATE t_user 
SET status = 1, 
    update_time = NOW()
WHERE username = 'admin';

-- 2. 添加更多测试账户（可选）
INSERT INTO t_user (username, password, nickname, email, role, status) VALUES
('student1', '$2a$10$BvFA576YTDvvxhE2zFiDQu8QLiAQBqPNCl1qmrRpbl7M6VreFN2dm', '学霸小王', 'student1@example.com', 0, 1),
('student2', '$2a$10$BvFA576YTDvvxhE2zFiDQu8QLiAQBqPNCl1qmrRpbl7M6VreFN2dm', '文艺小张', 'student2@example.com', 0, 1),
('teacher1', '$2a$10$BvFA576YTDvvxhE2zFiDQu8QLiAQBqPNCl1qmrRpbl7M6VreFN2dm', '李老师', 'teacher1@example.com', 1, 1)
ON DUPLICATE KEY UPDATE 
    nickname = VALUES(nickname),
    email = VALUES(email),
    update_time = NOW();

-- 3. 检查用户表状态
SELECT 
    id,
    username,
    nickname,
    role,
    status,
    CASE role 
        WHEN 0 THEN '普通用户' 
        WHEN 1 THEN '管理员' 
    END as role_name,
    CASE status 
        WHEN 0 THEN '禁用' 
        WHEN 1 THEN '正常' 
    END as status_name,
    create_time,
    update_time
FROM t_user 
ORDER BY role DESC, id;

-- 4. 验证修复结果
SELECT 
    '管理员账户状态' as check_item,
    COUNT(*) as count,
    GROUP_CONCAT(username) as usernames
FROM t_user 
WHERE role = 1 AND status = 1
UNION ALL
SELECT 
    '普通用户账户状态',
    COUNT(*),
    GROUP_CONCAT(username)
FROM t_user 
WHERE role = 0 AND status = 1;