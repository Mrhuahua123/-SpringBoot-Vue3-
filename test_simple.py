#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
简单测试用户状态API
"""

import requests
import json
import time

BASE_URL = "http://localhost:8080/api"

def test_user_status():
    print("=== 测试用户状态API ===\n")
    
    # 1. 登录获取token
    print("1. 登录获取管理员token...")
    try:
        login_data = {
            "username": "admin",
            "password": "123456"
        }
        login_resp = requests.post(f"{BASE_URL}/user/login", json=login_data)
        login_result = login_resp.json()
        
        if login_result.get("code") == 200:
            token = login_result["data"]["token"]
            print(f"   登录成功，token获取")
        else:
            print(f"   登录失败: {login_result.get('message')}")
            return
    except Exception as e:
        print(f"   登录异常: {e}")
        return
    
    print()
    
    # 2. 获取用户列表
    print("2. 获取用户列表...")
    try:
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {token}"
        }
        
        users_resp = requests.get(f"{BASE_URL}/admin/users?page=1&size=10", headers=headers)
        users_result = users_resp.json()
        
        if users_result.get("code") == 200:
            users = users_result["data"]["records"]
            print(f"   获取成功，用户数量: {len(users)}")
            
            # 显示用户状态
            print("   用户状态详情:")
            for user in users:
                status_text = "正常(1)" if user.get("status") == 1 else "禁用(0)"
                role_text = "管理员" if user.get("role") == 1 else "普通用户"
                print(f"     - {user.get('username')} ({user.get('nickname')}): 角色={role_text}, 状态={status_text}")
        else:
            print(f"   获取用户列表失败: {users_result.get('message')}")
    except Exception as e:
        print(f"   获取用户列表失败: {e}")
    
    print()
    
    # 3. 测试修改用户状态
    print("3. 测试修改用户状态API...")
    try:
        # 找测试用户
        test_user = None
        for user in users:
            if user.get("username") == "testuser":
                test_user = user
                break
        
        if test_user:
            print(f"   找到测试用户: {test_user.get('username')} (当前状态: {test_user.get('status')})")
            
            # 切换状态
            new_status = 0 if test_user.get("status") == 1 else 1
            print(f"   尝试修改状态为: {new_status}")
            
            update_resp = requests.put(
                f"{BASE_URL}/admin/users/{test_user.get('id')}/status?status={new_status}",
                headers=headers
            )
            update_result = update_resp.json()
            
            print(f"   修改响应: code={update_result.get('code')}, message={update_result.get('message')}")
            
            # 验证修改
            time.sleep(1)
            verify_resp = requests.get(f"{BASE_URL}/admin/users?page=1&size=10", headers=headers)
            verify_result = verify_resp.json()
            
            updated_user = None
            for user in verify_result["data"]["records"]:
                if user.get("id") == test_user.get("id"):
                    updated_user = user
                    break
            
            if updated_user:
                print(f"   验证新状态: {updated_user.get('status')} (原状态: {test_user.get('status')})")
            
            # 恢复原状态
            print("   恢复原状态...")
            requests.put(
                f"{BASE_URL}/admin/users/{test_user.get('id')}/status?status={test_user.get('status')}",
                headers=headers
            )
            print("   状态已恢复")
        else:
            print("   未找到测试用户")
    except Exception as e:
        print(f"   修改状态失败: {e}")
    
    print()
    print("=== 测试完成 ===")
    print()
    print("总结:")
    print("1. 数据库设计: status=0(禁用), status=1(正常)")
    print("2. 前端显示: 已修复为 status=1显示'正常', status=0显示'禁用'")
    print("3. 操作逻辑: 启用->status=1, 禁用->status=0")

if __name__ == "__main__":
    test_user_status()