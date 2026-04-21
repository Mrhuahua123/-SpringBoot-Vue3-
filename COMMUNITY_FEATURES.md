# 校园阅读社区 - 社区功能规划

## 🎯 目标
将基础阅读系统升级为活跃的校园阅读社区，增加用户互动和社交功能。

## 📋 功能模块

### 1. 书评与评论系统 📝
#### 功能描述
- 用户可以对图书发表书评
- 其他用户可以回复和点赞
- 支持富文本编辑（图片、表情、格式）
- 书评评分系统（1-5星）

#### 数据库设计
```sql
-- 书评表
CREATE TABLE t_review (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    book_id BIGINT NOT NULL COMMENT '图书ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    content TEXT NOT NULL COMMENT '评论内容',
    rating TINYINT DEFAULT 5 COMMENT '评分(1-5)',
    like_count INT DEFAULT 0 COMMENT '点赞数',
    reply_count INT DEFAULT 0 COMMENT '回复数',
    status TINYINT DEFAULT 1 COMMENT '状态: 0-隐藏 1-正常',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_book (book_id),
    INDEX idx_user (user_id),
    INDEX idx_time (create_time)
);

-- 评论回复表
CREATE TABLE t_review_reply (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    review_id BIGINT NOT NULL COMMENT '书评ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    content TEXT NOT NULL COMMENT '回复内容',
    parent_id BIGINT DEFAULT 0 COMMENT '父回复ID',
    like_count INT DEFAULT 0 COMMENT '点赞数',
    status TINYINT DEFAULT 1 COMMENT '状态',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_review (review_id),
    INDEX idx_user (user_id)
);

-- 点赞记录表
CREATE TABLE t_like_record (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    target_type TINYINT NOT NULL COMMENT '目标类型: 1-书评 2-回复',
    target_id BIGINT NOT NULL COMMENT '目标ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_like (target_type, target_id, user_id)
);
```

### 2. 阅读打卡系统 🎯
#### 功能描述
- 每日阅读打卡功能
- 连续打卡天数统计
- 打卡日历视图
- 打卡分享功能

#### 数据库设计
```sql
-- 打卡记录表
CREATE TABLE t_checkin_record (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL COMMENT '用户ID',
    checkin_date DATE NOT NULL COMMENT '打卡日期',
    reading_time INT DEFAULT 0 COMMENT '阅读时长(分钟)',
    book_id BIGINT COMMENT '阅读的图书ID',
    content VARCHAR(500) COMMENT '打卡内容',
    images VARCHAR(1000) COMMENT '打卡图片',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_checkin (user_id, checkin_date),
    INDEX idx_date (checkin_date)
);

-- 用户打卡统计表
CREATE TABLE t_checkin_stat (
    user_id BIGINT PRIMARY KEY COMMENT '用户ID',
    total_days INT DEFAULT 0 COMMENT '总打卡天数',
    continuous_days INT DEFAULT 0 COMMENT '连续打卡天数',
    total_time INT DEFAULT 0 COMMENT '总阅读时长(分钟)',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### 3. 用户社交系统 👥
#### 功能描述
- 用户关注/粉丝系统
- 私信功能
- @提及功能
- 用户主页展示

#### 数据库设计
```sql
-- 关注关系表
CREATE TABLE t_follow (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    follower_id BIGINT NOT NULL COMMENT '关注者ID',
    following_id BIGINT NOT NULL COMMENT '被关注者ID',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_follow (follower_id, following_id),
    INDEX idx_follower (follower_id),
    INDEX idx_following (following_id)
);

-- 私信表
CREATE TABLE t_message (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    sender_id BIGINT NOT NULL COMMENT '发送者ID',
    receiver_id BIGINT NOT NULL COMMENT '接收者ID',
    content TEXT NOT NULL COMMENT '消息内容',
    is_read TINYINT DEFAULT 0 COMMENT '是否已读: 0-未读 1-已读',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_sender (sender_id),
    INDEX idx_receiver (receiver_id),
    INDEX idx_time (create_time)
);
```

### 4. 阅读小组系统 👨‍👩‍👧‍👦
#### 功能描述
- 创建阅读小组
- 小组讨论区
- 小组阅读任务
- 小组排行榜

#### 数据库设计
```sql
-- 阅读小组表
CREATE TABLE t_reading_group (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL COMMENT '小组名称',
    description VARCHAR(500) COMMENT '小组描述',
    cover VARCHAR(255) COMMENT '小组封面',
    creator_id BIGINT NOT NULL COMMENT '创建者ID',
    member_count INT DEFAULT 1 COMMENT '成员数量',
    status TINYINT DEFAULT 1 COMMENT '状态: 0-关闭 1-正常',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 小组成员表
CREATE TABLE t_group_member (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    group_id BIGINT NOT NULL COMMENT '小组ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    role TINYINT DEFAULT 0 COMMENT '角色: 0-成员 1-管理员',
    join_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_member (group_id, user_id),
    INDEX idx_group (group_id),
    INDEX idx_user (user_id)
);

-- 小组讨论表
CREATE TABLE t_group_post (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    group_id BIGINT NOT NULL COMMENT '小组ID',
    user_id BIGINT NOT NULL COMMENT '发布者ID',
    title VARCHAR(200) COMMENT '帖子标题',
    content TEXT NOT NULL COMMENT '帖子内容',
    like_count INT DEFAULT 0 COMMENT '点赞数',
    comment_count INT DEFAULT 0 COMMENT '评论数',
    status TINYINT DEFAULT 1 COMMENT '状态',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_group (group_id),
    INDEX idx_user (user_id),
    INDEX idx_time (create_time)
);
```

### 5. 排行榜系统 🏆
#### 功能描述
- 阅读时长排行榜
- 打卡天数排行榜
- 书评数量排行榜
- 小组活跃度排行榜

#### 数据库设计
```sql
-- 排行榜缓存表
CREATE TABLE t_ranking (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    rank_type TINYINT NOT NULL COMMENT '排行榜类型: 1-阅读时长 2-打卡天数 3-书评数量',
    period_type TINYINT NOT NULL COMMENT '统计周期: 1-日榜 2-周榜 3-月榜 4-总榜',
    rank_date DATE NOT NULL COMMENT '统计日期',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    score INT NOT NULL COMMENT '得分',
    rank INT NOT NULL COMMENT '排名',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_type_date (rank_type, period_type, rank_date),
    INDEX idx_user (user_id)
);
```

## 🚀 实现计划

### 第一阶段：基础社区功能（1-2周）
1. ✅ 书评系统（评论、回复、点赞）
2. ✅ 阅读打卡系统
3. ✅ 用户关注功能

### 第二阶段：社交互动（2-3周）
1. 🔄 私信系统
2. 🔄 阅读小组
3. 🔄 @提及功能

### 第三阶段：数据与激励（1-2周）
1. 📊 排行榜系统
2. 🎁 积分奖励系统
3. 📈 数据统计面板

## 💡 技术实现要点

### 前端实现
1. **书评组件**：支持富文本编辑、图片上传、表情选择
2. **打卡组件**：日历视图、时长记录、内容分享
3. **消息组件**：实时消息、未读提示、消息列表
4. **小组组件**：小组创建、成员管理、讨论区

### 后端实现
1. **实时消息**：WebSocket实现即时通讯
2. **缓存优化**：Redis缓存排行榜和热门内容
3. **文件存储**：图片和文件上传到云存储
4. **搜索功能**：Elasticsearch实现全文搜索

### 性能优化
1. **分页加载**：评论、消息列表分页
2. **懒加载**：图片和内容懒加载
3. **CDN加速**：静态资源CDN分发
4. **数据库索引**：优化查询性能

## 🎨 用户体验设计

### 界面设计原则
1. **简洁明了**：功能清晰，操作简单
2. **社交互动**：突出点赞、评论、分享
3. **个性化**：用户主页、阅读偏好
4. **移动优先**：响应式设计，移动端优化

### 交互设计
1. **即时反馈**：操作后立即显示结果
2. **引导提示**：新功能引导和提示
3. **错误处理**：友好的错误提示和解决方案
4. **加载状态**：清晰的加载进度和状态

## 📊 数据指标

### 核心指标
1. **日活跃用户**（DAU）
2. **用户留存率**
3. **平均阅读时长**
4. **社区互动率**（评论/点赞/分享）

### 增长指标
1. **新用户注册数**
2. **内容生产量**（书评/打卡）
3. **社交关系数**（关注/粉丝）
4. **小组活跃度**

## 🔧 开发规范

### 代码规范
1. **命名规范**：统一的前后端命名约定
2. **注释规范**：必要的代码注释和文档
3. **提交规范**：清晰的Git提交信息
4. **测试规范**：单元测试和集成测试

### 部署规范
1. **环境分离**：开发、测试、生产环境
2. **监控告警**：系统监控和错误告警
3. **备份策略**：数据库和文件备份
4. **安全策略**：权限控制和数据安全

## 📞 支持与维护

### 技术支持
1. **文档完善**：详细的开发和使用文档
2. **问题反馈**：快速响应和解决问题
3. **版本更新**：定期功能更新和优化

### 社区运营
1. **内容运营**：优质内容推荐和引导
2. **用户激励**：积分奖励和排行榜
3. **活动策划**：阅读挑战和社区活动

---

**最后更新**：2026-04-21  
**版本**：v1.0.0  
**状态**：规划阶段 📋