import pymysql
import sys

try:
    # 连接数据库
    connection = pymysql.connect(
        host='localhost',
        user='root',
        password='123456',
        database='campus_reading',
        charset='utf8mb4'
    )
    
    with connection.cursor() as cursor:
        # 重置密码为123456的BCrypt哈希
        password_hash = '$2a$10$BvFA576YTDvvxhE2zFiDQu8QLiAQBqPNCl1qmrRpbl7M6VreFN2dm'
        
        # 更新管理员密码
        sql = "UPDATE t_user SET password = %s WHERE username = 'admin'"
        cursor.execute(sql, (password_hash,))
        print("管理员密码已重置")
        
        # 更新测试用户密码
        sql = "UPDATE t_user SET password = %s WHERE username = 'testuser'"
        cursor.execute(sql, (password_hash,))
        print("测试用户密码已重置")
        
        # 提交事务
        connection.commit()
        
        # 验证
        sql = """
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
            END as status_name
        FROM t_user 
        ORDER BY role DESC, id
        """
        cursor.execute(sql)
        results = cursor.fetchall()
        
        print("\n当前用户状态:")
        print("-" * 60)
        for row in results:
            print(f"用户名: {row[0]}, 昵称: {row[1]}, 角色: {row[2]}, 状态: {row[3]}")
        print("-" * 60)
        
except pymysql.Error as e:
    print(f"数据库错误: {e}")
    sys.exit(1)
finally:
    if connection:
        connection.close()

print("\n密码重置完成！现在可以使用以下账户登录:")
print("1. 管理员: admin / 123456")
print("2. 测试用户: testuser / 123456")