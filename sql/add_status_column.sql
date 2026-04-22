-- 为 t_review 表添加 status 列
USE campus_reading;

-- 检查表结构
DESC t_review;

-- 添加 status 列（如果不存在）
ALTER TABLE t_review 
ADD COLUMN IF NOT EXISTS status TINYINT NOT NULL DEFAULT 1 COMMENT '状态: 0-隐藏 1-正常' 
AFTER reply_count;

-- 更新现有数据，设置默认状态为1（正常）
UPDATE t_review SET status = 1 WHERE status IS NULL OR status = '';

-- 验证修改
DESC t_review;

-- 查看示例数据
SELECT id, book_id, user_id, score, status, create_time FROM t_review LIMIT 5;