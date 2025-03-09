import Testing
import XCTest
@testable import EatBreakFirst

struct BreakfastTrackerTests {
    
    // 清理测试环境，确保每次测试之前都是干净的
    private func cleanupTestEnvironment() {
        // 清理共享的UserDefaults中的数据
        let appGroupIdentifier = "group.com.masheal2333.EatBreakFirst"
        let defaults = UserDefaults(suiteName: appGroupIdentifier)
        defaults?.removeObject(forKey: "breakfastRecords")
        defaults?.synchronize()
    }
    
    // 测试记录早餐状态的功能
    @Test func testRecordBreakfast() async throws {
        // 清理测试环境
        cleanupTestEnvironment()
        
        // 创建BreakfastTracker实例
        let tracker = BreakfastTracker()
        
        // 记录已吃早餐
        tracker.recordBreakfast(eaten: true)
        
        // 验证当天的早餐状态已被正确记录
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let hasEatenToday = tracker.hasEatenBreakfast(on: today)
        
        #expect(hasEatenToday == true, "早餐状态应该被记录为已吃")
    }
    
    // 测试记录没吃早餐的功能
    @Test func testRecordSkippedBreakfast() async throws {
        // 清理测试环境
        cleanupTestEnvironment()
        
        // 创建BreakfastTracker实例
        let tracker = BreakfastTracker()
        
        // 记录没吃早餐
        tracker.recordBreakfast(eaten: false)
        
        // 验证当天的早餐状态已被正确记录
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let hasEatenToday = tracker.hasEatenBreakfast(on: today)
        
        #expect(hasEatenToday == false, "早餐状态应该被记录为没吃")
    }
    
    // 测试从小组件记录早餐状态的静态方法
    @Test func testRecordBreakfastFromWidget() async throws {
        // 清理测试环境
        cleanupTestEnvironment()
        
        // 使用静态方法记录已吃早餐
        BreakfastTracker.recordBreakfastFromWidget(eaten: true)
        
        // 创建BreakfastTracker实例并加载数据
        let tracker = BreakfastTracker()
        
        // 验证当天的早餐状态已被正确记录
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let hasEatenToday = tracker.hasEatenBreakfast(on: today)
        
        #expect(hasEatenToday == true, "从小组件记录的早餐状态应该被正确保存")
    }
    
    // 测试连续天数计算
    @Test func testStreakCalculation() async throws {
        // 清理测试环境
        cleanupTestEnvironment()
        
        // 创建BreakfastTracker实例
        let tracker = BreakfastTracker()
        
        // 记录连续3天吃早餐
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        for i in 0..<3 {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            tracker.recordBreakfast(eaten: true, for: date)
        }
        
        // 验证连续天数计算正确
        #expect(tracker.streakCount == 3, "连续天数应该为3")
    }
    
    // 测试当记录中断时连续天数重置
    @Test func testStreakResetWhenBreak() async throws {
        // 清理测试环境
        cleanupTestEnvironment()
        
        // 创建BreakfastTracker实例
        let tracker = BreakfastTracker()
        
        // 记录今天和前天吃早餐，昨天没吃
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        
        tracker.recordBreakfast(eaten: true, for: today)
        tracker.recordBreakfast(eaten: false, for: yesterday)
        tracker.recordBreakfast(eaten: true, for: twoDaysAgo)
        
        // 验证连续天数为1（只有今天）
        #expect(tracker.streakCount == 1, "中断后连续天数应该重置为1")
    }
    
    // 测试多实例加载同步
    @Test func testMultipleInstancesSync() async throws {
        // 清理测试环境
        cleanupTestEnvironment()
        
        // 创建第一个BreakfastTracker实例并记录数据
        let tracker1 = BreakfastTracker()
        tracker1.recordBreakfast(eaten: true)
        
        // 确保数据已同步到磁盘
        BreakfastTracker.shared.synchronize()
        
        // 创建第二个BreakfastTracker实例
        let tracker2 = BreakfastTracker()
        
        // 获取今天的日期
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // 验证第二个实例能读取到第一个实例保存的数据
        let hasEatenToday = tracker2.hasEatenBreakfast(on: today)
        #expect(hasEatenToday == true, "第二个实例应该能读取到第一个实例保存的数据")
    }
} 