//
//  EatBreakfirstWidgetBundle.swift
//  EatBreakfirstWidget
//
//  Created by Sheng Ma on 3/7/25.
//

import WidgetKit
import SwiftUI

@main
struct EatBreakfirstWidgetBundle: WidgetBundle {
    init() {
        // 确保UserDefaults正确设置
        let appGroupIdentifier = "group.com.masheal2333.EatBreakFirst"
        let defaults = UserDefaults(suiteName: appGroupIdentifier)
        if defaults == nil {
            print("警告: 无法创建带有 App Group 的 UserDefaults，可能是项目设置问题")
        } else {
            print("小组件: 成功使用 App Group \(appGroupIdentifier) 初始化 UserDefaults")
        }
    }

    var body: some Widget {
        EatBreakfirstWidget()
    }
}
