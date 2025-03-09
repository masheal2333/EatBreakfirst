//
//  AppIntent.swift
//  EatBreakfirstWidget
//
//  Created by Sheng Ma on 3/7/25.
//

import WidgetKit
import AppIntents
import SwiftUI

// 小组件配置选项
struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "早餐记录小组件配置" }
    static var description: IntentDescription { "配置早餐记录小组件的显示选项" }
    
    // 不再需要配置参数
}

// 标记吃了早餐的意图
struct MarkBreakfastEatenIntent: AppIntent {
    static var title: LocalizedStringResource = "标记已吃早餐"
    static var description = IntentDescription("记录今天已经吃了早餐")
    
    // 添加小组件交互支持
    static var openAppWhenRun: Bool = false
    
    func perform() async throws -> some IntentResult {
        print("Widget: MarkBreakfastEatenIntent.perform() 开始执行")
        
        // 使用与应用相同的方式记录早餐状态
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // 从共享的UserDefaults中读取现有记录
        var records: [Date: Bool] = [:]
        if let data = BreakfastTracker.shared.data(forKey: "breakfastRecords") {
            let decoder = JSONDecoder()
            if let recordsArray = try? decoder.decode([BreakfastRecord].self, from: data) {
                print("Widget: 成功从UserDefaults加载了\(recordsArray.count)条记录")
                records = Dictionary(uniqueKeysWithValues: recordsArray.map { 
                    (Date(timeIntervalSince1970: $0.date), $0.hasEaten) 
                })
            } else {
                print("Widget: 无法解码从UserDefaults加载的记录数据")
            }
        } else {
            print("Widget: UserDefaults中没有找到breakfastRecords数据")
        }
        
        // 更新今天的记录
        records[today] = true
        
        // 将更新后的记录保存回去
        let encoder = JSONEncoder()
        let recordsArray = records.map { BreakfastRecord(date: $0.key.timeIntervalSince1970, hasEaten: $0.value) }
        if let encoded = try? encoder.encode(recordsArray) {
            print("Widget: 正在保存\(recordsArray.count)条记录到UserDefaults")
            BreakfastTracker.shared.set(encoded, forKey: "breakfastRecords")
            BreakfastTracker.shared.synchronize()
            print("Widget: 已记录今天已吃早餐，并执行了synchronize")
        } else {
            print("Widget: 编码记录数组失败")
        }
        
        // 立即更新小组件
        print("Widget: 强制刷新小组件")
        WidgetCenter.shared.reloadAllTimelines()
        
        // 使用多次延迟更新，确保小组件能够获取到最新数据
        let delayTimes = [0.3, 0.8, 2.0] // 多个时间点进行更新
        
        for (index, delay) in delayTimes.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                print("Widget: 第\(index + 1)次延迟更新小组件 (延迟\(delay)秒)")
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
        
        print("Widget: MarkBreakfastEatenIntent.perform() 执行完成")
        return .result()
    }
}

// 标记没吃早餐的意图
struct MarkBreakfastSkippedIntent: AppIntent {
    static var title: LocalizedStringResource = "标记没吃早餐"
    static var description = IntentDescription("记录今天没有吃早餐")
    
    // 添加小组件交互支持
    static var openAppWhenRun: Bool = false
    
    func perform() async throws -> some IntentResult {
        print("Widget: MarkBreakfastSkippedIntent.perform() 开始执行")
        
        // 使用与应用相同的方式记录早餐状态
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // 从共享的UserDefaults中读取现有记录
        var records: [Date: Bool] = [:]
        if let data = BreakfastTracker.shared.data(forKey: "breakfastRecords") {
            let decoder = JSONDecoder()
            if let recordsArray = try? decoder.decode([BreakfastRecord].self, from: data) {
                print("Widget: 成功从UserDefaults加载了\(recordsArray.count)条记录")
                records = Dictionary(uniqueKeysWithValues: recordsArray.map { 
                    (Date(timeIntervalSince1970: $0.date), $0.hasEaten) 
                })
            } else {
                print("Widget: 无法解码从UserDefaults加载的记录数据")
            }
        } else {
            print("Widget: UserDefaults中没有找到breakfastRecords数据")
        }
        
        // 更新今天的记录
        records[today] = false
        
        // 将更新后的记录保存回去
        let encoder = JSONEncoder()
        let recordsArray = records.map { BreakfastRecord(date: $0.key.timeIntervalSince1970, hasEaten: $0.value) }
        if let encoded = try? encoder.encode(recordsArray) {
            print("Widget: 正在保存\(recordsArray.count)条记录到UserDefaults")
            BreakfastTracker.shared.set(encoded, forKey: "breakfastRecords")
            BreakfastTracker.shared.synchronize()
            print("Widget: 已记录今天没吃早餐，并执行了synchronize")
        } else {
            print("Widget: 编码记录数组失败")
        }
        
        // 立即更新小组件
        print("Widget: 强制刷新小组件")
        WidgetCenter.shared.reloadAllTimelines()
        
        // 使用多次延迟更新，确保小组件能够获取到最新数据
        let delayTimes = [0.3, 0.8, 2.0] // 多个时间点进行更新
        
        for (index, delay) in delayTimes.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                print("Widget: 第\(index + 1)次延迟更新小组件 (延迟\(delay)秒)")
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
        
        print("Widget: MarkBreakfastSkippedIntent.perform() 执行完成")
        return .result()
    }
}

// BreakfastRecord struct is already defined in EatBreakfirstWidget.swift
