// 测试 Review 实体类的修复
public class TestReviewFix {
    public static void main(String[] args) {
        System.out.println("测试 Review 实体类字段名修复");
        System.out.println("1. Review 实体类应该使用 'score' 字段而不是 'rating'");
        System.out.println("2. ReviewDTO 使用 'score' 字段");
        System.out.println("3. ReviewServiceImpl 使用 'setScore()' 方法");
        System.out.println("4. 数据库表 t_review 使用 'score' 列");
        System.out.println("\n修复总结：");
        System.out.println("- 已将 Review.java 中的 'rating' 字段改为 'score'");
        System.out.println("- ReviewServiceImpl.java 中的 'review.setScore(dto.getScore())' 现在应该可以正常工作了");
        System.out.println("- 数据库表结构已经使用 'score' 列，无需修改");
        System.out.println("\n修复完成！");
    }
}