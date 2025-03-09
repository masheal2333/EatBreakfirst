import Testing
import XCTest
@testable import EatBreakFirst
import SwiftUI
import WidgetKit

// 集成测试，验证整个应用的主要功能
struct IntegrationTests {
    
    // 清理测试环境，确保每次测试之前都是干净的
    private func cleanupTestEnvironment() {
        // 清理共享的UserDefaults中的数据
        let appGroupIdentifier = "group.com.masheal2333.EatBreakFirst"
        let defaults = UserDefaults(suiteName: appGroupIdentifier)
        defaults?.removeObject(forKey: "breakfastRecords")
        defaults?.removeObject(forKey: "longestStreak")
        defaults?.synchronize()
    }
    
    // 测试主流程：记录早餐 -> 查看记录 -> 计算连续天数
    @Test func testMainFlowRecordAndRead() async throws {
        // 清理测试环境
        cleanupTestEnvironment()
        
        // 创建应用状态管理器
        let breakfastTracker = BreakfastTracker()
        
        // 模拟用户操作：记录吃了早餐
        breakfastTracker.recordBreakfast(eaten: true)
        
        // 验证早餐记录状态
        let today = Calendar.current.startOfDay(for: Date())
        let hasEaten = breakfastTracker.hasEatenBreakfast(on: today)
        
        #expect(hasEaten == true, "应该记录为已吃早餐")
        #expect(breakfastTracker.streakCount > 0, "连续天数应该大于0")
        
        // 模拟应用退出再启动的场景
        let newTracker = BreakfastTracker()
        let hasEatenAfterReload = newTracker.hasEatenBreakfast(on: today)
        
        #expect(hasEatenAfterReload == true, "应用重启后应当保持已吃状态")
        #expect(newTracker.streakCount > 0, "重启后连续天数应该保持")
    }
    
    // 测试用户界面中的记录操作是否正确修改状态
    @Test func testUIInteractionChangesState() async throws {
        // 清理测试环境
        cleanupTestEnvironment()
        
        // 创建应用状态管理器
        let breakfastTracker = BreakfastTracker()
        
        // 创建视图环境
        // 注意：这里不直接创建ContentView，避免异步初始化问题
        let _ = breakfastTracker
        
        // 获取今天的日期
        let today = Calendar.current.startOfDay(for: Date())
        
        // 确认初始状态
        #expect(breakfastTracker.hasEatenBreakfast(on: today) == nil, "初始状态应该是未记录")
        
        // 由于无法直接测试UI交互，我们在这里直接调用底层函数模拟
        // 在实际测试中，可能会使用XCTest的UI测试能力
        breakfastTracker.recordBreakfast(eaten: true)
        
        // 验证状态已更改
        #expect(breakfastTracker.hasEatenBreakfast(on: today) == true, "状态应该被更新为已吃早餐")
    }
    
    // 测试多天记录和统计功能
    @Test func testMultiDayRecording() async throws {
        // 清理测试环境
        cleanupTestEnvironment()
        
        // 创建应用状态管理器
        let breakfastTracker = BreakfastTracker()
        
        // 模拟记录多天的早餐状态
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // 记录连续5天吃早餐
        for i in 0..<5 {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            breakfastTracker.recordBreakfast(eaten: true, for: date)
        }
        
        // 验证连续天数计算
        #expect(breakfastTracker.streakCount == 5, "5天连续吃早餐应该计算为5天连续记录")
        
        // 在连续记录中插入一天未吃
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today)!
        breakfastTracker.recordBreakfast(eaten: false, for: threeDaysAgo)
        
        // 验证连续天数重置
        #expect(breakfastTracker.streakCount == 3, "连续天数应该被重置为3（今天和前两天）")
        
        // 检查成就 - 移除对私有方法的直接调用
        // 通过验证achievements数组间接检查成就状态
        if !breakfastTracker.achievements.isEmpty {
            #expect(breakfastTracker.achievements[0].isUnlocked, "第一个成就（记录第一天）应该被解锁")
        }
    }
    
    // 测试提醒功能配置
    @Test func testReminderConfiguration() async throws {
        // 清理测试环境
        cleanupTestEnvironment()
        
        // 创建应用状态管理器
        let breakfastTracker = BreakfastTracker()
        
        // 设置提醒
        breakfastTracker.isReminderEnabled = true
        let testTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
        breakfastTracker.reminderTime = testTime
        
        // 使用synchronize方法代替调用私有方法
        BreakfastTracker.shared.synchronize()
        
        // 创建新实例验证设置是否保存
        let newTracker = BreakfastTracker()
        
        #expect(newTracker.isReminderEnabled, "提醒应该被启用")
        
        let savedHour = Calendar.current.component(.hour, from: newTracker.reminderTime)
        let savedMinute = Calendar.current.component(.minute, from: newTracker.reminderTime)
        
        #expect(savedHour == 8, "提醒时间应该设置为8点")
        #expect(savedMinute == 0, "提醒分钟应该设置为0分")
    }
    
    // 测试应用与小组件之间的数据同步
    // 注意：由于环境限制，这个测试只能模拟同步过程
    @Test func testAppWidgetSynchronization() async throws {
        // 清理测试环境
        cleanupTestEnvironment()
        
        // 1. 从应用记录早餐状态
        let appTracker = BreakfastTracker()
        appTracker.recordBreakfast(eaten: true)
        
        // 确保数据已同步到磁盘
        BreakfastTracker.shared.synchronize()
        
        // 2. 模拟小组件读取数据
        // 注意：真实的小组件测试需要特殊的测试环境
        // 这里我们只能通过间接方式验证
        let appGroupIdentifier = "group.com.masheal2333.EatBreakFirst"
        let widgetDefaults = UserDefaults(suiteName: appGroupIdentifier)
        
        // 验证数据存在于共享的UserDefaults中
        #expect(widgetDefaults?.data(forKey: "breakfastRecords") != nil, "数据应该存储在共享的UserDefaults中")
        
        // 3. 从小组件记录早餐状态
        // 清除之前的记录
        cleanupTestEnvironment()
        
        // 使用小组件的方式记录状态
        BreakfastTracker.recordBreakfastFromWidget(eaten: false)
        
        // 创建新的应用实例读取数据
        let newAppTracker = BreakfastTracker()
        
        // 验证应用能读取到小组件记录的状态
        let today = Calendar.current.startOfDay(for: Date())
        let hasEatenToday = newAppTracker.hasEatenBreakfast(on: today)
        
        #expect(hasEatenToday == false, "应用应该能读取到小组件记录的没吃早餐状态")
    }
} 