import Testing
import XCTest
@testable import EatBreakFirst

// 修改测试以避免直接依赖小组件模块
struct BreakfastSyncTests {
    
    // 清理测试环境，确保每次测试之前都是干净的
    private func cleanupTestEnvironment() {
        // 清理共享的UserDefaults中的数据
        let appGroupIdentifier = "group.com.masheal2333.EatBreakFirst"
        let defaults = UserDefaults(suiteName: appGroupIdentifier)
        defaults?.removeObject(forKey: "breakfastRecords")
        defaults?.synchronize()
    }
    
    // 测试从应用记录早餐状态后，数据能被正确保存到共享存储
    @Test func testAppToSharedStorage() async throws {
        // 清理测试环境
        cleanupTestEnvironment()
        
        // 创建应用中的BreakfastTracker实例
        let appTracker = BreakfastTracker()
        
        // 在应用中标记为已吃早餐
        appTracker.recordBreakfast(eaten: true)
        
        // 确保数据已经同步到磁盘
        BreakfastTracker.shared.synchronize()
        
        // 验证数据已保存到共享存储
        let appGroupIdentifier = "group.com.masheal2333.EatBreakFirst"
        let defaults = UserDefaults(suiteName: appGroupIdentifier)
        let data = defaults?.data(forKey: "breakfastRecords")
        
        #expect(data != nil, "数据应该被保存到共享存储")
        
        // 验证数据内容正确
        if let data = data {
            let decoder = JSONDecoder()
            if let recordsArray = try? decoder.decode([BreakfastRecord].self, from: data) {
                #expect(!recordsArray.isEmpty, "保存的记录数组不应为空")
                
                // 获取今天的日期时间戳
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                let todayTimestamp = today.timeIntervalSince1970
                
                // 查找今天的记录
                let todayRecord = recordsArray.first { record in
                    let recordDate = Date(timeIntervalSince1970: record.date)
                    let recordDay = calendar.startOfDay(for: recordDate)
                    return recordDay.timeIntervalSince1970 == todayTimestamp
                }
                
                #expect(todayRecord != nil, "应该找到今天的记录")
                #expect(todayRecord?.hasEaten == true, "今天的记录应该为已吃早餐")
            } else {
                XCTFail("无法解码保存的数据")
            }
        }
    }
    
    // 测试从共享存储读取数据到应用
    @Test func testSharedStorageToApp() async throws {
        // 清理测试环境
        cleanupTestEnvironment()
        
        // 准备共享存储中的数据
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todayTimestamp = today.timeIntervalSince1970
        
        let recordsArray = [BreakfastRecord(date: todayTimestamp, hasEaten: false)]
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(recordsArray) {
            let appGroupIdentifier = "group.com.masheal2333.EatBreakFirst"
            let defaults = UserDefaults(suiteName: appGroupIdentifier)
            defaults?.set(encoded, forKey: "breakfastRecords")
            defaults?.synchronize()
        } else {
            XCTFail("无法编码测试数据")
        }
        
        // 创建应用中的BreakfastTracker实例并加载数据
        let appTracker = BreakfastTracker()
        
        // 验证应用能正确读取共享存储中的数据
        let hasEatenToday = appTracker.hasEatenBreakfast(on: today)
        
        #expect(hasEatenToday == false, "应用应该读取到没吃早餐的状态")
    }
    
    // 测试从小组件静态方法记录数据
    @Test func testWidgetStaticMethodToSharedStorage() async throws {
        // 清理测试环境
        cleanupTestEnvironment()
        
        // 使用小组件的静态方法记录数据
        BreakfastTracker.recordBreakfastFromWidget(eaten: true)
        
        // 验证数据已保存到共享存储
        let appGroupIdentifier = "group.com.masheal2333.EatBreakFirst"
        let defaults = UserDefaults(suiteName: appGroupIdentifier)
        let data = defaults?.data(forKey: "breakfastRecords")
        
        #expect(data != nil, "数据应该被保存到共享存储")
        
        // 验证数据内容正确
        if let data = data {
            let decoder = JSONDecoder()
            if let recordsArray = try? decoder.decode([BreakfastRecord].self, from: data) {
                #expect(!recordsArray.isEmpty, "保存的记录数组不应为空")
                
                // 获取今天的日期时间戳
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                let todayTimestamp = today.timeIntervalSince1970
                
                // 查找今天的记录
                let todayRecord = recordsArray.first { record in
                    let recordDate = Date(timeIntervalSince1970: record.date)
                    let recordDay = calendar.startOfDay(for: recordDate)
                    return recordDay.timeIntervalSince1970 == todayTimestamp
                }
                
                #expect(todayRecord != nil, "应该找到今天的记录")
                #expect(todayRecord?.hasEaten == true, "今天的记录应该为已吃早餐")
            } else {
                XCTFail("无法解码保存的数据")
            }
        }
    }
    
    // 测试从共享存储到小组件静态方法读取数据
    @Test func testSharedStorageToWidgetStaticMethod() async throws {
        // 清理测试环境
        cleanupTestEnvironment()
        
        // 准备共享存储中的数据
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todayTimestamp = today.timeIntervalSince1970
        
        let recordsArray = [BreakfastRecord(date: todayTimestamp, hasEaten: true)]
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(recordsArray) {
            let appGroupIdentifier = "group.com.masheal2333.EatBreakFirst"
            let defaults = UserDefaults(suiteName: appGroupIdentifier)
            defaults?.set(encoded, forKey: "breakfastRecords")
            defaults?.synchronize()
        } else {
            XCTFail("无法编码测试数据")
        }
        
        // 使用小组件静态方法更新记录
        BreakfastTracker.recordBreakfastFromWidget(eaten: false)
        
        // 验证数据已更新
        let defaults = UserDefaults(suiteName: "group.com.masheal2333.EatBreakFirst")
        if let data = defaults?.data(forKey: "breakfastRecords") {
            let decoder = JSONDecoder()
            if let updatedRecordsArray = try? decoder.decode([BreakfastRecord].self, from: data) {
                #expect(!updatedRecordsArray.isEmpty, "更新后的记录数组不应为空")
                
                // 查找今天的记录
                let todayRecord = updatedRecordsArray.first { record in
                    let recordDate = Date(timeIntervalSince1970: record.date)
                    let recordDay = calendar.startOfDay(for: recordDate)
                    return recordDay.timeIntervalSince1970 == todayTimestamp
                }
                
                #expect(todayRecord != nil, "应该找到今天的记录")
                #expect(todayRecord?.hasEaten == false, "今天的记录应该被更新为没吃早餐")
            } else {
                XCTFail("无法解码更新后的数据")
            }
        } else {
            XCTFail("找不到更新后的数据")
        }
    }
    
    // 测试数据同步的一致性
    @Test func testDataConsistency() async throws {
        // 清理测试环境
        cleanupTestEnvironment()
        
        // 1. 首先从应用记录数据
        let appTracker = BreakfastTracker()
        appTracker.recordBreakfast(eaten: true)
        BreakfastTracker.shared.synchronize()
        
        // 2. 然后从小组件静态方法更新数据
        BreakfastTracker.recordBreakfastFromWidget(eaten: false)
        
        // 3. 创建新的应用实例读取数据
        let newAppTracker = BreakfastTracker()
        
        // 验证应用能读取到最新状态
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let hasEatenToday = newAppTracker.hasEatenBreakfast(on: today)
        
        #expect(hasEatenToday == false, "应用应该读取到最新的没吃早餐状态")
    }
} 