-- ============================================================
-- 校园阅读社区系统 - 社区讨论相关表
-- ============================================================

USE campus_reading;

-- ----------------------------
-- 1. 社区讨论表
-- ----------------------------
DROP TABLE IF EXISTS t_discussion;
CREATE TABLE t_discussion (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '讨论ID',
    user_id BIGINT NOT NULL COMMENT '发布用户ID',
    title VARCHAR(200) NOT NULL COMMENT '讨论标题',
    content TEXT NOT NULL COMMENT '讨论内容',
    tag VARCHAR(50) DEFAULT NULL COMMENT '标签',
    like_count INT DEFAULT 0 COMMENT '点赞数',
    reply_count INT DEFAULT 0 COMMENT '回复数',
    view_count INT DEFAULT 0 COMMENT '浏览数',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '状态: 0-隐藏 1-正常',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    KEY idx_user (user_id),
    KEY idx_tag (tag),
    KEY idx_create_time (create_time DESC)
) ENGINE=InnoDB COMMENT='社区讨论表';

-- ----------------------------
-- 2. 讨论回复表
-- ----------------------------
DROP TABLE IF EXISTS t_discussion_reply;
CREATE TABLE t_discussion_reply (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '回复ID',
    discussion_id BIGINT NOT NULL COMMENT '讨论ID',
    user_id BIGINT NOT NULL COMMENT '回复用户ID',
    content VARCHAR(1000) NOT NULL COMMENT '回复内容',
    parent_id BIGINT DEFAULT NULL COMMENT '父回复ID(用于嵌套回复)',
    like_count INT DEFAULT 0 COMMENT '点赞数',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '状态: 0-隐藏 1-正常',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '回复时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    KEY idx_discussion (discussion_id),
    KEY idx_user (user_id),
    KEY idx_parent (parent_id)
) ENGINE=InnoDB COMMENT='讨论回复表';

-- ----------------------------
-- 3. 讨论点赞表
-- ----------------------------
DROP TABLE IF EXISTS t_discussion_like;
CREATE TABLE t_discussion_like (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '点赞ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    discussion_id BIGINT DEFAULT NULL COMMENT '讨论ID',
    reply_id BIGINT DEFAULT NULL COMMENT '回复ID',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',
    UNIQUE KEY uk_user_discussion (user_id, discussion_id),
    UNIQUE KEY uk_user_reply (user_id, reply_id),
    CHECK ((discussion_id IS NOT NULL AND reply_id IS NULL) OR (discussion_id IS NULL AND reply_id IS NOT NULL))
) ENGINE=InnoDB COMMENT='讨论点赞表';

-- ----------------------------
-- 4. 插入示例数据
-- ----------------------------
-- 示例讨论
INSERT INTO t_discussion (user_id, title, content, tag, like_count, reply_count, view_count, create_time) VALUES
(2, '《百年孤独》重读感悟', '加西亚·马尔克斯的魔幻现实主义手法，将现实与幻想完美结合。重读后发现更多细节...', '文学经典', 56, 24, 320, '2026-04-21 10:30:00'),
(2, '《三体》科学设定讨论', '在刘慈欣的《三体》中，从三体问题到黑暗森林理论，这些科学设定是否合理？', '科幻讨论', 42, 18, 280, '2026-04-20 15:20:00'),
(2, '求推荐温暖治愈系小说', '春天到了，想读一些温暖治愈的小说，大家有什么推荐吗？', '好书推荐', 38, 32, 210, '2026-04-19 09:15:00');

-- 示例回复
INSERT INTO t_discussion_reply (discussion_id, user_id, content, create_time) VALUES
(1, 2, '我也很喜欢这本书，特别是布恩迪亚家族的宿命感，让人深思。', '2026-04-21 11:00:00'),
(1, 1, '魔幻现实主义的代表作，每一遍读都有新发现。', '2026-04-21 11:30:00'),
(2, 2, '黑暗森林理论确实很有启发性，但感觉过于悲观了。', '2026-04-20 16:00:00'),
(3, 2, '推荐《小王子》，虽然简单但很治愈。', '2026-04-19 10:00:00'),
(3, 1, '《解忧杂货店》也不错，温暖又感人。', '2026-04-19 10:30:00');

-- 更新讨论的回复计数
UPDATE t_discussion d 
SET reply_count = (
    SELECT COUNT(*) FROM t_discussion_reply r 
    WHERE r.discussion_id = d.id
);

-- 创建讨论回复的视图（方便查询）
CREATE OR REPLACE VIEW v_discussion_detail AS
SELECT 
    d.*,
    u.username,
    u.nickname,
    u.avatar
FROM t_discussion d
LEFT JOIN t_user u ON d.user_id = u.id;

CREATE OR REPLACE VIEW v_discussion_reply_detail AS
SELECT 
    r.*,
    u.username,
    u.nickname,
    u.avatar,
    pu.nickname AS parent_user_nickname
FROM t_discussion_reply r
LEFT JOIN t_user u ON r.user_id = u.id
LEFT JOIN t_discussion_reply pr ON r.parent_id = pr.id
LEFT JOIN t_user pu ON pr.user_id = pu.id;