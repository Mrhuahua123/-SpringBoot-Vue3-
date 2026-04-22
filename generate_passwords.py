#!/usr/bin/env python3
"""
密码哈希生成工具
用于修复校园阅读项目的密码哈希问题
"""

import bcrypt
import sys

def generate_bcrypt_hash(password):
    """生成BCrypt哈希"""
    # 生成盐并哈希密码
    salt = bcrypt.gensalt(rounds=10, prefix=b'2a')  # 使用2a前缀
    hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed.decode('utf-8')

def verify_password(password, hashed_password):
    """验证密码"""
    return bcrypt.checkpw(password.encode('utf-8'), hashed_password.encode('utf-8'))

def main():
    print("=" * 60)
    print("校园阅读项目 - 密码哈希修复工具")
    print("=" * 60)
    
    # 需要修复的用户
    users = [
        {"username": "admin", "password": "123456"},
        {"username": "testuser", "password": "test123"}
    ]
    
    print("\n生成新的密码哈希:")
    print("-" * 40)
    
    sql_statements = []
    
    for user in users:
        hashed = generate_bcrypt_hash(user["password"])
        print(f"用户名: {user['username']}")
        print(f"密码: {user['password']}")
        print(f"BCrypt哈希: {hashed}")
        
        # 验证生成的哈希
        is_valid = verify_password(user["password"], hashed)
        print(f"验证结果: {'✓ 有效' if is_valid else '✗ 无效'}")
        
        # 生成SQL语句
        sql = f"UPDATE t_user SET password = '{hashed}' WHERE username = '{user['username']}';"
        sql_statements.append(sql)
        print(f"SQL: {sql}")
        print()
    
    print("\n" + "=" * 60)
    print("SQL更新脚本:")
    print("=" * 60)
    for sql in sql_statements:
        print(sql)
    
    print("\n" + "=" * 60)
    print("执行步骤:")
    print("=" * 60)
    print("1. 连接到MySQL数据库:")
    print("   mysql -u root -p123456 campus_reading")
    print("\n2. 执行以下SQL语句:")
    for i, sql in enumerate(sql_statements, 1):
        print(f"   {i}. {sql}")
    
    print("\n3. 验证修复:")
    print("   SELECT username, password FROM t_user WHERE username IN ('admin', 'testuser');")
    
    print("\n" + "=" * 60)
    print("注意:")
    print("=" * 60)
    print("1. 确保数据库服务正在运行")
    print("2. 执行前备份重要数据")
    print("3. 修复后测试登录功能")

if __name__ == "__main__":
    try:
        main()
    except ImportError:
        print("错误: 需要安装bcrypt库")
        print("安装命令: pip install bcrypt")
        sys.exit(1)
    except Exception as e:
        print(f"错误: {e}")
        sys.exit(1)