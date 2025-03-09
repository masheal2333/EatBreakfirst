//
//  LocalizationManager.swift
//  EatBreakFirst
//
//  Created on 3/9/25.
//

import Foundation

// 本地化字符串管理器
class LocalizationManager {
    static let shared = LocalizationManager()
    
    private init() {
        // 初始化时不需要额外操作
    }
    
    // 获取本地化字符串
    func localizedString(_ key: LocalizedStringKey) -> String {
        let language = UserRoleManager.shared.getCurrentLanguage()
        
        switch language {
        case .english:
            return key.englishValue
        case .chinese:
            return key.chineseValue
        }
    }
}

// 简化访问本地化字符串的函数
func L(_ key: LocalizedStringKey) -> String {
    return LocalizationManager.shared.localizedString(key)
} 