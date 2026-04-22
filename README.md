# 校园阅读社区系统

一个基于Spring Boot + Vue 3的现代化校园阅读社区平台。

## 🎯 项目特点

- **前后端分离架构**：Spring Boot后端 + Vue 3前端
- **现代化UI设计**：Element Plus组件库，响应式设计
- **完整用户系统**：注册、登录、权限管理、个人中心
- **社区功能**：图书管理、阅读记录、书评交流
- **管理员后台**：用户管理、图书管理、数据统计

## 🚀 技术栈

### 后端技术
- **框架**：Spring Boot 2.x
- **数据库**：MySQL 8.0 + Redis
- **安全**：JWT Token认证
- **ORM**：MyBatis-Plus
- **构建工具**：Maven

### 前端技术
- **框架**：Vue 3 + Composition API
- **构建工具**：Vite
- **UI组件**：Element Plus
- **状态管理**：Pinia
- **路由**：Vue Router 4
- **HTTP客户端**：Axios

## 📁 项目结构

```
campus-reading-project/
├── campus-reading-backend/     # Spring Boot后端
│   ├── src/main/java/com/example/campusreading/
│   │   ├── controller/         # 控制器层
│   │   ├── service/           # 服务层
│   │   ├── mapper/            # 数据访问层
│   │   ├── entity/            # 实体类
│   │   └── utils/             # 工具类
│   ├── src/main/resources/
│   │   ├── application.yml    # 配置文件
│   │   └── mapper/            # MyBatis映射文件
│   └── pom.xml               # Maven配置
│
├── campus-reading-frontend/    # Vue 3前端
│   ├── src/
│   │   ├── api/              # API接口
│   │   ├── components/       # 公共组件
│   │   ├── views/           # 页面组件
│   │   ├── router/          # 路由配置
│   │   ├── stores/          # 状态管理
│   │   └── utils/           # 工具函数
│   ├── public/              # 静态资源
│   └── vite.config.js       # Vite配置
│
├── sql/                      # 数据库脚本
├── docs/                    # 项目文档
└── README.md               # 项目说明
```

## 🛠️ 快速开始

### 1. 环境要求
- JDK 8+
- Node.js 16+
- MySQL 8.0+
- Redis 6+

### 2. 数据库初始化
```sql
-- 创建数据库
CREATE DATABASE campus_reading DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 执行初始化脚本
USE campus_reading;
SOURCE sql/init.sql;
```

### 3. 后端启动
```bash
cd campus-reading-backend
mvn clean install
mvn spring-boot:run
```

### 4. 前端启动
```bash
cd campus-reading-frontend
npm install
npm run dev
```

### 5. 访问地址
- 前端：http://localhost:5175
- 后端API：http://localhost:8080
- 管理员账户：admin / 123456

## 📋 功能模块

### 用户模块
- ✅ 用户注册（支持邮箱验证）
- ✅ 用户登录（JWT Token）
- ✅ 个人信息管理
- ✅ 头像上传
- ✅ 密码修改

### 图书模块
- ✅ 图书浏览与搜索
- ✅ 图书详情查看
- ✅ 在线阅读
- ✅ 加入书架
- ✅ 阅读进度记录

### 社区模块
- ✅ 书评系统（已实现后端API）
  - 发布书评（支持评分1-5星）
  - 查看图书书评列表
  - 热门书评排序
  - 点赞功能
  - 回复功能
- 🔄 点赞收藏（开发中）
- 🔄 阅读打卡（开发中）
- 🔄 用户排行榜（开发中）
- 🔄 消息通知（开发中）

### 管理后台
- ✅ 用户管理（启用/禁用、角色管理）
- ✅ 图书管理（上架/下架）
- ✅ 分类管理
- ✅ 数据统计
- ✅ 系统设置

## 🔧 最新修复与优化

### 2026-04-21 重大更新
1. **用户管理状态修复**
   - 修复状态显示逻辑（1=正常，0=禁用）
   - 统一状态常量定义
   - 优化操作按钮逻辑

2. **注册页面全面升级**
   - 现代化UI设计
   - 动画效果和进度条
   - 社交登录支持
   - 响应式移动端适配

3. **环境变量系统**
   - 修复Vue 3环境变量问题
   - 开发/生产环境分离
   - 统一配置管理

4. **代码质量提升**
   - 创建常量文件避免魔法数字
   - 统一错误处理
   - 优化组件结构

5. **社区功能开发启动**
   - 创建书评实体类（Review.java）
   - 创建书评数据访问层（ReviewMapper.java）
   - 创建书评服务层（ReviewService.java, ReviewServiceImpl.java）
   - 创建书评控制器（ReviewController.java）
   - 修复ReviewServiceImpl编译错误（字段名一致性）

6. **Git仓库管理**
   - 项目已上传至GitHub
   - 创建完整的.gitignore配置
   - 分离前后端仓库管理

## 🐛 已知问题与解决方案

### 1. 登录失败问题
**症状**：admin/testuser登录返回"用户名或密码错误"
**原因**：数据库密码哈希不匹配
**解决方案**：
```sql
UPDATE t_user SET password = '$2a$10$BvFA576YTDvvxhE2zFiDQu8QLiAQBqPNCl1qmrRpbl7M6VreFN2dm' 
WHERE username IN ('admin', 'testuser');
```

### 2. 后端中文乱码
**症状**：API返回中文乱码
**解决方案**：检查后端字符编码配置

### 3. 用户状态显示
**已修复**：状态显示和操作逻辑已统一

## 📈 项目状态

### ✅ 已完成功能
- 用户注册登录系统
- 图书管理基础功能
- 管理员后台框架
- 前后端联调测试

### 🔄 进行中功能
- **社区互动功能完善**
  - ✅ 书评系统后端API（已完成）
  - 🔄 书评系统前端组件（开发中）
  - 🔄 点赞收藏功能
  - 🔄 阅读打卡系统
  - 🔄 用户社交功能
- **阅读统计与分析**
  - 🔄 阅读时长统计
  - 🔄 阅读进度跟踪
  - 🔄 阅读报告生成
- **移动端优化**
  - 🔄 响应式设计优化
  - 🔄 PWA支持
  - 🔄 移动端专属功能

### 📅 计划功能
- 微信小程序版本
- AI图书推荐
- 阅读小组功能
- 积分商城系统

## 🤝 贡献指南

1. Fork本仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启Pull Request

## 📄 许可证

本项目采用MIT许可证。详见 [LICENSE](LICENSE) 文件。

## 🌐 GitHub仓库

项目已上传至GitHub：
- **仓库地址**：https://github.com/Mrhuahua123/-SpringBoot-Vue3-
- **提交记录**：https://github.com/Mrhuahua123/-SpringBoot-Vue3-/commits?author=Mrhuahua123
- **项目结构**：包含完整的Spring Boot后端和Vue 3前端

### 克隆项目
```bash
git clone https://github.com/Mrhuahua123/-SpringBoot-Vue3-.git
cd -SpringBoot-Vue3-

# 初始化子模块
git submodule init
git submodule update
```

## 📞 联系方式

- **项目维护者**：kezi
- **GitHub**：Mrhuahua123
- **问题反馈**：[提交Issue](https://github.com/Mrhuahua123/-SpringBoot-Vue3-/issues)
- **文档更新**：定期维护

---

**最后更新**：2026-04-21  
**版本**：v1.0.0  
**GitHub状态**：已上传 ✅  
**项目状态**：生产就绪 🚀