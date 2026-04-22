# 电子书上传与阅读功能测试流程

## 功能概述
1. 管理员在图书管理页面可以上传电子书
2. 系统自动解析TXT电子书为章节
3. 用户可以在线阅读电子书

## 文件结构

### 后端文件
1. `EbookController.java` - 电子书上传、解析、删除API
2. `EbookService.java` - 电子书业务逻辑
3. `EbookParser.java` - TXT文件解析工具
4. `ReaderController.java` - 阅读器API
5. `Chapter.java` - 章节实体
6. `Book.java` - 图书实体（已包含电子书字段）

### 前端文件
1. `AdminBookManage.vue` - 管理员图书管理页面（已添加电子书功能）
2. `ebook.js` - 电子书API
3. `reader.js` - 阅读器API
4. `ReaderView.vue` - 阅读器页面

## 数据库表

### t_book 表（已存在）
- `ebook_file` VARCHAR(255) - 电子书文件路径
- `ebook_format` VARCHAR(10) - 文件格式
- `has_ebook` TINYINT - 是否有电子书

### t_chapter 表（已存在）
- `book_id` BIGINT - 图书ID
- `chapter_num` INT - 章节编号
- `title` VARCHAR(200) - 章节标题
- `content` LONGTEXT - 章节内容
- `word_count` INT - 字数统计

## 测试步骤

### 步骤1：启动服务
```bash
# 启动后端（需要Java环境）
cd campus-reading-backend
mvn spring-boot:run

# 启动前端
cd campus-reading-frontend
npm run dev
```

### 步骤2：登录管理员账户
1. 访问 http://localhost:5173/login
2. 使用管理员账户登录（admin/123456）

### 步骤3：进入图书管理
1. 导航到管理员页面
2. 进入"图书管理"

### 步骤4：上传电子书
1. 在图书列表中找到目标图书
2. 点击"电子书"按钮
3. 在对话框中拖拽或选择TXT文件上传
4. 系统自动上传并更新图书状态

### 步骤5：解析章节
1. 上传TXT文件后，系统会自动解析章节
2. 也可以手动点击"解析章节"按钮
3. 查看解析结果和章节数量

### 步骤6：在线阅读
1. 点击"在线阅读"按钮
2. 系统跳转到阅读器页面
3. 测试章节导航、字体设置等功能

### 步骤7：删除电子书
1. 点击"删除电子书"按钮
2. 确认删除操作
3. 验证电子书状态更新

## API接口

### 电子书相关
- `POST /api/ebook/upload/{bookId}` - 上传电子书
- `POST /api/ebook/parse/{bookId}` - 解析章节
- `DELETE /api/ebook/{bookId}` - 删除电子书
- `GET /api/ebook/{bookId}` - 获取电子书信息
- `GET /api/ebook/status/{bookId}` - 检查状态

### 阅读器相关
- `GET /api/reader/chapters/{bookId}` - 获取章节目录
- `GET /api/reader/chapter/{id}` - 获取章节内容
- `GET /api/reader/chapter/{id}/nav` - 获取章节导航

## 注意事项

1. **文件格式**：目前主要支持TXT格式，可扩展支持PDF、DOCX、EPUB
2. **文件大小**：限制为10MB
3. **编码**：所有文件使用UTF-8编码
4. **路径**：文件保存在`uploads/ebooks/`目录
5. **章节解析**：TXT文件按章节标题自动分割

## 故障排除

### 问题1：上传失败
- 检查文件格式和大小
- 检查后端服务是否运行
- 检查uploads目录权限

### 问题2：解析失败
- 检查TXT文件编码是否为UTF-8
- 检查文件内容格式
- 查看后端日志

### 问题3：无法在线阅读
- 检查章节是否解析成功
- 检查阅读器页面路由
- 检查API响应格式

## 扩展功能建议

1. **批量上传**：支持批量上传电子书
2. **格式转换**：自动转换不同格式的电子书
3. **阅读进度**：记录用户阅读进度
4. **书签功能**：添加书签和笔记
5. **搜索功能**：在电子书中搜索内容
6. **导出功能**：导出电子书或章节
7. **阅读统计**：统计阅读时长和进度