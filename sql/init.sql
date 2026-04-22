-- ============================================================
-- 校园阅读社区系统 数据库初始化脚本
-- 数据库: campus_reading
-- 字符集: utf8mb4
-- ============================================================

CREATE DATABASE IF NOT EXISTS campus_reading DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE campus_reading;

-- ----------------------------
-- 1. 用户表
-- ----------------------------
DROP TABLE IF EXISTS t_user;
CREATE TABLE t_user (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    username VARCHAR(50) NOT NULL COMMENT '用户名',
    password VARCHAR(100) NOT NULL COMMENT '密码(BCrypt加密)',
    nickname VARCHAR(50) DEFAULT NULL COMMENT '昵称',
    avatar VARCHAR(255) DEFAULT NULL COMMENT '头像URL',
    email VARCHAR(100) DEFAULT NULL COMMENT '邮箱',
    phone VARCHAR(20) DEFAULT NULL COMMENT '手机号',
    bio VARCHAR(500) DEFAULT NULL COMMENT '个人简介',
    role TINYINT NOT NULL DEFAULT 0 COMMENT '角色: 0-普通用户 1-管理员',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '状态: 0-禁用 1-正常',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_username (username),
    UNIQUE KEY uk_email (email)
) ENGINE=InnoDB COMMENT='用户表';

-- ----------------------------
-- 2. 图书分类表
-- ----------------------------
DROP TABLE IF EXISTS t_category;
CREATE TABLE t_category (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '分类ID',
    name VARCHAR(50) NOT NULL COMMENT '分类名称',
    description VARCHAR(200) DEFAULT NULL COMMENT '分类描述',
    sort_num INT DEFAULT 0 COMMENT '排序号',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间'
) ENGINE=InnoDB COMMENT='图书分类表';

-- ----------------------------
-- 3. 图书表
-- ----------------------------
DROP TABLE IF EXISTS t_book;
CREATE TABLE t_book (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '图书ID',
    title VARCHAR(200) NOT NULL COMMENT '书名',
    author VARCHAR(100) DEFAULT NULL COMMENT '作者',
    publisher VARCHAR(100) DEFAULT NULL COMMENT '出版社',
    isbn VARCHAR(20) DEFAULT NULL COMMENT 'ISBN',
    publish_date DATE DEFAULT NULL COMMENT '出版日期',
    category_id BIGINT DEFAULT NULL COMMENT '分类ID',
    cover VARCHAR(255) DEFAULT NULL COMMENT '封面图片URL',
    description TEXT COMMENT '内容简介',
    total_score DOUBLE DEFAULT 0 COMMENT '总评分',
    score_count INT DEFAULT 0 COMMENT '评分人数',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '状态: 0-下架 1-上架',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    KEY idx_title (title),
    KEY idx_author (author),
    KEY idx_category (category_id)
) ENGINE=InnoDB COMMENT='图书表';

-- ----------------------------
-- 4. 书评表
-- ----------------------------
DROP TABLE IF EXISTS t_review;
CREATE TABLE t_review (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '书评ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    book_id BIGINT NOT NULL COMMENT '图书ID',
    score TINYINT NOT NULL COMMENT '评分(1-5)',
    content TEXT NOT NULL COMMENT '评论内容',
    like_count INT DEFAULT 0 COMMENT '点赞数',
    reply_count INT DEFAULT 0 COMMENT '回复数',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '状态: 0-隐藏 1-正常',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    KEY idx_user (user_id),
    KEY idx_book (book_id)
) ENGINE=InnoDB COMMENT='书评表';

-- ----------------------------
-- 5. 评论回复表
-- ----------------------------
DROP TABLE IF EXISTS t_reply;
CREATE TABLE t_reply (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '回复ID',
    review_id BIGINT NOT NULL COMMENT '书评ID',
    user_id BIGINT NOT NULL COMMENT '回复用户ID',
    content VARCHAR(500) NOT NULL COMMENT '回复内容',
    parent_id BIGINT DEFAULT NULL COMMENT '父回复ID',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '回复时间',
    KEY idx_review (review_id)
) ENGINE=InnoDB COMMENT='评论回复表';

-- ----------------------------
-- 6. 点赞表
-- ----------------------------
DROP TABLE IF EXISTS t_like;
CREATE TABLE t_like (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '点赞ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    review_id BIGINT NOT NULL COMMENT '书评ID',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',
    UNIQUE KEY uk_user_review (user_id, review_id)
) ENGINE=InnoDB COMMENT='点赞表';

-- ----------------------------
-- 7. 书架表
-- ----------------------------
DROP TABLE IF EXISTS t_bookshelf;
CREATE TABLE t_bookshelf (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    book_id BIGINT NOT NULL COMMENT '图书ID',
    read_status TINYINT NOT NULL DEFAULT 1 COMMENT '阅读状态: 1-想读 2-在读 3-已读',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_user_book (user_id, book_id)
) ENGINE=InnoDB COMMENT='书架表';

-- ----------------------------
-- 8. 打卡记录表
-- ----------------------------
DROP TABLE IF EXISTS t_checkin;
CREATE TABLE t_checkin (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '打卡ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    checkin_date DATE NOT NULL COMMENT '打卡日期',
    read_duration INT DEFAULT 0 COMMENT '阅读时长(分钟)',
    note VARCHAR(500) DEFAULT NULL COMMENT '阅读心得',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '打卡时间',
    UNIQUE KEY uk_user_date (user_id, checkin_date)
) ENGINE=InnoDB COMMENT='打卡记录表';

-- ----------------------------
-- 9. 通知表
-- ----------------------------
DROP TABLE IF EXISTS t_notification;
CREATE TABLE t_notification (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '通知ID',
    receiver_id BIGINT NOT NULL COMMENT '接收用户ID',
    sender_id BIGINT DEFAULT NULL COMMENT '发送用户ID',
    type VARCHAR(20) NOT NULL COMMENT '通知类型: REVIEW_REPLY/LIKE/SYSTEM',
    target_id BIGINT DEFAULT NULL COMMENT '关联对象ID',
    content VARCHAR(500) NOT NULL COMMENT '通知内容',
    is_read TINYINT NOT NULL DEFAULT 0 COMMENT '是否已读: 0-未读 1-已读',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    KEY idx_receiver (receiver_id, is_read)
) ENGINE=InnoDB COMMENT='通知表';

-- ----------------------------
-- 10. 操作日志表
-- ----------------------------
DROP TABLE IF EXISTS t_operation_log;
CREATE TABLE t_operation_log (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '日志ID',
    user_id BIGINT DEFAULT NULL COMMENT '操作用户ID',
    operation VARCHAR(50) NOT NULL COMMENT '操作类型',
    target VARCHAR(50) DEFAULT NULL COMMENT '操作对象',
    detail VARCHAR(500) DEFAULT NULL COMMENT '操作详情',
    ip VARCHAR(50) DEFAULT NULL COMMENT 'IP地址',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间'
) ENGINE=InnoDB COMMENT='操作日志表';

-- ----------------------------
-- 初始化数据
-- ----------------------------
-- 管理员账号 (密码: 123456)
INSERT INTO t_user (username, password, nickname, role, status) VALUES
('admin', '$2b$10$fnZnZ8AgO2.mBXpVA75w3uch/nI6.WNS8GSv//HLT.jwZZH45FjSO', '管理员', 1, 0);

-- 测试用户 (密码: 123456)
INSERT INTO t_user (username, password, nickname, email, role, status) VALUES
('testuser', '$2a$10$BvFA576YTDvvxhE2zFiDQu8QLiAQBqPNCl1qmrRpbl7M6VreFN2dm', '书虫小明', 'test@example.com', 0, 1);

-- 图书分类
INSERT INTO t_category (name, description, sort_num) VALUES
('文学小说', '中外文学名著、当代小说等', 1),
('历史传记', '历史研究、人物传记', 2),
('科学技术', '自然科学、工程技术', 3),
('经济管理', '经济学、管理学著作', 4),
('计算机', '编程、算法、人工智能等', 5),
('哲学心理', '哲学、心理学', 6),
('社会科学', '社会学、政治学、法学', 7),
('艺术设计', '美术、设计、摄影', 8);

-- 示例图书
INSERT INTO t_book (title, author, publisher, isbn, category_id, cover, description, total_score, score_count, status) VALUES
('活着', '余华', '作家出版社', '9787506365437', 1, '/uploads/covers/huozhe.jpg', '地主少爷福贵嗜赌成性，终于赌光了家业一贫如洗。', 4.8, 128, 1),
('三体', '刘慈欣', '重庆出版社', '9787536692930', 3, '/uploads/covers/santi.jpg', '文化大革命如火如荼进行的同时，军方探寻外星文明的绝密计划取得了突破性进展。', 4.9, 256, 1),
('百年孤独', '加西亚·马尔克斯', '南海出版公司', '9787544253994', 1, '/uploads/covers/bainiangudu.jpg', '《百年孤独》是魔幻现实主义文学的代表作，描写了布恩迪亚家族七代人的传奇故事。', 4.7, 89, 1),
('深入理解Java虚拟机', '周志明', '机械工业出版社', '9787111641247', 5, '/uploads/covers/jvm.jpg', '这是一部从工作原理和工程实践两个维度深入剖析JVM的著作。', 4.6, 67, 1),
('Spring Boot实战', 'Craig Walls', '人民邮电出版社', '9787115433145', 5, '/uploads/covers/springboot.jpg', '本书以Spring Boot为中心，以Spring框架为纽带，介绍Spring Boot的使用方法。', 4.5, 45, 1);

-- 示例书评
INSERT INTO t_review (user_id, book_id, score, content, like_count, create_time) VALUES
(2, 1, 5, '这是一本让人读后久久不能平静的书。余华用最朴实的语言，讲述了最沉重的故事。', 12, '2024-03-15 10:30:00'),
(2, 2, 5, '三体让我重新认识了科幻文学的魅力，刘慈欣的想象力令人叹为观止。', 23, '2024-03-16 14:20:00');

-- ----------------------------
-- �½ڱ�
-- ----------------------------
DROP TABLE IF EXISTS t_chapter;
CREATE TABLE t_chapter (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '�½�ID',
    book_id BIGINT NOT NULL COMMENT 'ͼ��ID',
    chapter_num INT NOT NULL COMMENT '�½����',
    title VARCHAR(200) NOT NULL COMMENT '�½ڱ���',
    content LONGTEXT COMMENT '�½�����',
    word_count INT DEFAULT 0 COMMENT '����',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '״̬: 0-���� 1-��ʾ',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '����ʱ��',
    KEY idx_book_chapter (book_id, chapter_num)
) ENGINE=InnoDB COMMENT='�½ڱ�';

-- ʾ���½�
INSERT INTO t_chapter (book_id, chapter_num, title, content, word_count, status) VALUES
(1, 1, '��һ��', '�ұ���������ʮ���ʱ�򣬻����һ�����ֺ��е�ְҵ��ȥ����ռ�����ҥ����һ����������죬����ͬһֻ�ҷɵ���ȸ���ε���֪�˺�������Ĵ�����Ұ��

�ҵ����ε����Ѿ�Ū���������ʲô�ط�����ֻ֪�������Ϸ�����Ⱥɽ�ʹ��֮�䣬��һ��������ׯ�ں�Ұ�ݵĵط������ߵ��������ۣ������ҵ��Ҹ��ط�ЪһЪ��

����һ���������˺ܾã�����һ�úܴ������֦Ҷ��ï���������Ҷ�ķ�϶�����������ڵ�����������ϸС�Ĺ�ߡ�

�ҵ��Ǹ������������Ǹ������š��Ҽ����汲�����ǵ�������������һ�����ų�������ôһ���ܼ��ӡ�

�������ʱ�򣬳Ժ��ζģ�ʲô�˵��¶��ɹ����Ұܹ��˼Ҳ�����һ�ٶ�Ķ��ȫ������������ҵ����һ�������ˡ�

�ҵ������Ժ��ҾͿ�ʼ�����˵�������룬����Ϊ�˻��ű��������ţ�������Ϊ�˻���֮����κ���������š�', 1250, 1),
(1, 2, '�ڶ���', '�ҵ����󲻵����꣬����Ҳ�����ˡ�����ͦ�Ŵ���ӣ��������ҽ�Ǯ�β���

��ʱ�������Ѿ��ᵽé��ȥס�ˡ���é���ְ���С��������©ˮ���η���©�硣����������ɨ�úܸɾ�����˵��ҲҪ������档

�����ǳ��������ϰ��Ů�������޸����ǵ��˰˱��ӵ�ù���������ʱ��������ͷ�������ܣ�����¥����졣

����������ʱ�������ҵ���˵��"���󰡣���Ҫ�ú����ˣ��ú��չ˼���ͺ��ӡ�"

�������󣬼������������졣������������ʱ���ݵ���ֻСè������ȴ�����������룬�⺢������һ���ܻ�������

����ʱ���Ѿ������ˣ�Ҳ�����ˡ�ÿ���첻�����µظɻ̫����ɽ�Żؼҡ������ڼҷ��ߡ������������ӡ����ǵ�������Ȼ�࣬��һ������һ��������̤ʵ�ġ�', 1180, 1),
(1, 3, '������', '���쳤�������ʱ�򣬷�ϼҲ�����ˡ���ϼ��������䣬���۾�����Ƥ�����ܺÿ���

����������ã���ʲô�óԵĶ��ȸ���ϼ����ϼ����·�Ժ������������ƨ�ɺ����ܡ����쵽�����ϼ�͸������

�Ǽ��꣬������Ȼ�࣬��һ������һ�𣬵�Ҳ���ð��ȡ���ÿ���ճ������������Ϣ�������ڼҲٳּ����չ��������ӡ�

���Ǻ�����û����ã��ͳ����ˡ�һ������꣬����������ˡ����Ǵ�����˶������е������ʳ��ȥ�Է���

�տ�ʼ��ʱ��ʳ�õĻ�ʳȷʵ�����������вˣ����׷��ܹ�����һ�����ܸ��ˣ����ú��������ˡ�

����û����ã���ʳ�Ͳ������ˡ���������һ��ֻ�ܺ�����ϡ�ࡣ���������Ƽ��ݣ���ϼҲ�ݵ�Ƥ����ͷ��

�������ۺ��ӣ����Լ����Ƿ���ʡ����������ͷ�ϼ�ȡ���˵��"���䣬��Ҳ�ó԰���"����Ц��˵��"�Ҳ�����"��֪������˵�ѣ�����û�в�����', 1120, 1);
