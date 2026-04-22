import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class PasswordResetTool {
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        
        // 生成新密码的哈希
        String password = "123456";
        String hashedPassword = encoder.encode(password);
        
        System.out.println("密码: " + password);
        System.out.println("BCrypt哈希: " + hashedPassword);
        System.out.println();
        
        // 验证现有哈希
        String existingHash = "$2a$10$aWHpq9t3RYKQ.Ndc.JGynuA9/dt.WVRTQXCPypkuDhoLR/hXcc7oO";
        boolean matches = encoder.matches(password, existingHash);
        System.out.println("现有哈希: " + existingHash);
        System.out.println("密码匹配: " + matches);
        System.out.println();
        
        // 生成SQL更新语句
        System.out.println("SQL更新语句:");
        System.out.println("UPDATE t_user SET password = '" + hashedPassword + "' WHERE username = 'admin';");
        System.out.println("UPDATE t_user SET password = '" + hashedPassword + "' WHERE username = 'testuser';");
        
        // 生成测试用户的哈希
        String testPassword = "test123";
        String testHashedPassword = encoder.encode(testPassword);
        System.out.println("\n测试用户密码: " + testPassword);
        System.out.println("测试用户哈希: " + testHashedPassword);
        System.out.println("UPDATE t_user SET password = '" + testHashedPassword + "' WHERE username = 'testuser';");
    }
}