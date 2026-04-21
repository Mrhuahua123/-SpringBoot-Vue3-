# 校园阅读社区系统 - 部署指南

## 📦 项目打包

### 1. 前端项目打包
```bash
# 进入前端目录
cd campus-reading-frontend

# 安装依赖（如果未安装）
npm install

# 构建生产版本
npm run build

# 构建结果在 dist/ 目录
```

### 2. 后端项目打包
```bash
# 进入后端目录
cd campus-reading-backend

# 使用Maven打包
mvn clean package -DskipTests

# 打包结果在 target/ 目录
# 主要文件：campus-reading-0.0.1-SNAPSHOT.jar
```

## 🚀 部署步骤

### 1. 环境准备
#### 服务器要求
- **操作系统**：Linux (Ubuntu 20.04+ / CentOS 7+)
- **Java环境**：JDK 8+
- **Node.js**：16+（仅前端构建需要）
- **数据库**：MySQL 8.0+，Redis 6+
- **Web服务器**：Nginx（推荐）

#### 端口规划
- **前端**：80/443 (HTTP/HTTPS)
- **后端API**：8080
- **MySQL**：3306
- **Redis**：6379

### 2. 数据库部署
```sql
-- 1. 创建数据库
CREATE DATABASE campus_reading DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 2. 创建用户并授权
CREATE USER 'campus_reading'@'%' IDENTIFIED BY 'StrongPassword123!';
GRANT ALL PRIVILEGES ON campus_reading.* TO 'campus_reading'@'%';
FLUSH PRIVILEGES;

-- 3. 导入数据
USE campus_reading;
SOURCE sql/init.sql;
```

### 3. Redis配置
```bash
# 安装Redis
sudo apt-get install redis-server

# 配置Redis（/etc/redis/redis.conf）
# 修改以下配置：
# bind 0.0.0.0
# requirepass YourRedisPassword
# maxmemory 256mb
# maxmemory-policy allkeys-lru

# 重启Redis
sudo systemctl restart redis
```

### 4. 后端部署
```bash
# 1. 上传JAR文件到服务器
scp target/campus-reading-0.0.1-SNAPSHOT.jar user@server:/opt/campus-reading/

# 2. 创建服务配置文件
sudo nano /etc/systemd/system/campus-reading.service
```

**服务配置文件内容：**
```ini
[Unit]
Description=Campus Reading Backend Service
After=network.target mysql.service redis.service

[Service]
Type=simple
User=campus
WorkingDirectory=/opt/campus-reading
ExecStart=/usr/bin/java -jar campus-reading-0.0.1-SNAPSHOT.jar
Restart=on-failure
RestartSec=10
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=campus-reading

[Install]
WantedBy=multi-user.target
```

```bash
# 3. 启动服务
sudo systemctl daemon-reload
sudo systemctl enable campus-reading
sudo systemctl start campus-reading

# 4. 查看服务状态
sudo systemctl status campus-reading
```

### 5. 前端部署
```bash
# 1. 上传前端文件到服务器
scp -r dist/* user@server:/var/www/campus-reading/

# 2. 配置Nginx
sudo nano /etc/nginx/sites-available/campus-reading
```

**Nginx配置文件：**
```nginx
server {
    listen 80;
    server_name your-domain.com;  # 修改为你的域名
    root /var/www/campus-reading;
    index index.html;

    # 前端路由支持
    location / {
        try_files $uri $uri/ /index.html;
    }

    # 后端API代理
    location /api {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # 超时设置
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # 静态文件缓存
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|woff|woff2|ttf|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # 上传文件代理
    location /uploads {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # Gzip压缩
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript 
               application/javascript application/xml+rss 
               application/json image/svg+xml;
}
```

```bash
# 3. 启用站点
sudo ln -s /etc/nginx/sites-available/campus-reading /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 6. HTTPS配置（可选但推荐）
```bash
# 使用Certbot获取SSL证书
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com

# 自动续期测试
sudo certbot renew --dry-run
```

## 🔧 环境配置

### 后端配置文件（application.yml）
```yaml
server:
  port: 8080
  servlet:
    context-path: /api

spring:
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://localhost:3306/campus_reading?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai&useSSL=false&allowPublicKeyRetrieval=true
    username: campus_reading
    password: StrongPassword123!
  
  data:
    redis:
      host: localhost
      port: 6379
      password: YourRedisPassword
      database: 0
      timeout: 5000ms
  
  servlet:
    multipart:
      max-file-size: 10MB
      max-request-size: 10MB

# 文件上传配置
file:
  upload-dir: /var/uploads/campus-reading
  access-path: /uploads

# JWT配置
jwt:
  secret: CampusReading2024SecretKeyForJWTTokenGenerationAndValidation
  expiration: 86400000  # 24小时

# 日志配置
logging:
  level:
    com.example.campusreading: DEBUG
  file:
    name: /var/log/campus-reading/app.log
  logback:
    rollingpolicy:
      max-file-size: 10MB
      max-history: 30
```

### 前端环境配置（.env.production）
```env
VITE_APP_TITLE=校园阅读社区
VITE_API_BASE_URL=/api
VITE_DEBUG=false
VITE_UPLOAD_URL=/api/uploads
```

## 📊 监控与维护

### 1. 日志查看
```bash
# 后端日志
sudo journalctl -u campus-reading -f
tail -f /var/log/campus-reading/app.log

# Nginx日志
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

### 2. 性能监控
```bash
# 查看系统资源
htop
free -h
df -h

# 查看服务状态
sudo systemctl status campus-reading
sudo systemctl status nginx
sudo systemctl status mysql
sudo systemctl status redis
```

### 3. 数据库备份
```bash
# 创建备份脚本
sudo nano /opt/backup/backup.sh
```

**备份脚本内容：**
```bash
#!/bin/bash
BACKUP_DIR="/opt/backup/data"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="campus_reading"
DB_USER="campus_reading"
DB_PASS="StrongPassword123!"

# 创建备份目录
mkdir -p $BACKUP_DIR

# 备份数据库
mysqldump -u$DB_USER -p$DB_PASS $DB_NAME | gzip > $BACKUP_DIR/${DB_NAME}_${DATE}.sql.gz

# 保留最近7天的备份
find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete

# 记录日志
echo "$(date): Backup completed for $DB_NAME" >> /var/log/backup.log
```

```bash
# 设置定时任务
sudo crontab -e
# 添加以下行（每天凌晨2点备份）
0 2 * * * /bin/bash /opt/backup/backup.sh
```

### 4. 安全配置
```bash
# 防火墙配置
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 22/tcp
sudo ufw enable

# 定期更新
sudo apt-get update
sudo apt-get upgrade -y

# 安全扫描
sudo apt-get install lynis
sudo lynis audit system
```

## 🐛 故障排除

### 常见问题1：后端启动失败
```bash
# 检查端口占用
sudo netstat -tlnp | grep :8080

# 检查Java版本
java -version

# 查看详细日志
sudo journalctl -u campus-reading --no-pager -n 100
```

### 常见问题2：数据库连接失败
```bash
# 测试数据库连接
mysql -u campus_reading -p -h localhost campus_reading

# 检查MySQL服务状态
sudo systemctl status mysql

# 检查防火墙
sudo ufw status
```

### 常见问题3：前端无法访问API
```bash
# 测试API连接
curl http://localhost:8080/api/health

# 检查Nginx配置
sudo nginx -t

# 查看Nginx错误日志
tail -f /var/log/nginx/error.log
```

### 常见问题4：文件上传失败
```bash
# 检查上传目录权限
ls -la /var/uploads/campus-reading

# 设置正确权限
sudo chown -R campus:www-data /var/uploads/campus-reading
sudo chmod -R 755 /var/uploads/campus-reading
```

## 🔄 更新部署

### 1. 后端更新
```bash
# 停止服务
sudo systemctl stop campus-reading

# 备份旧版本
cp /opt/campus-reading/campus-reading-0.0.1-SNAPSHOT.jar /opt/campus-reading/backup/

# 上传新版本
scp target/campus-reading-0.0.1-SNAPSHOT.jar user@server:/opt/campus-reading/

# 启动服务
sudo systemctl start campus-reading

# 验证更新
sudo systemctl status campus-reading
```

### 2. 前端更新
```bash
# 备份旧版本
cp -r /var/www/campus-reading /var/www/campus-reading-backup-$(date +%Y%m%d)

# 上传新版本
scp -r dist/* user@server:/var/www/campus-reading/

# 重启Nginx
sudo systemctl reload nginx
```

### 3. 数据库更新
```sql
-- 执行更新脚本
USE campus_reading;
SOURCE sql/update_v1.1.sql;
```

## 📞 技术支持

### 紧急联系方式
- **服务器运维**：系统管理员
- **数据库问题**：DBA团队
- **应用问题**：开发团队
- **网络问题**：网络管理员

### 监控告警
- **服务器监控**：CPU、内存、磁盘使用率
- **应用监控**：响应时间、错误率、吞吐量
- **业务监控**：用户活跃、交易量、转化率

### 应急预案
1. **服务器宕机**：自动切换到备用服务器
2. **数据库故障**：从备份恢复数据
3. **网络攻击**：启用WAF和DDoS防护
4. **数据丢失**：从备份恢复，调查原因

---

**最后更新**：2026-04-21  
**版本**：v1.0.0  
**状态**：生产就绪 🚀