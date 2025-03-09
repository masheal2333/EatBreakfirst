//
//  UserRoleManager.swift
//  EatBreakFirst
//
//  Created by Sheng Ma on 3/7/25.
//

import Foundation
import StoreKit

// 用户角色枚举
enum UserRole: String {
    case admin
    case user
}

// 支持的语言枚举
enum AppLanguage: String, CaseIterable {
    case chinese = "zh"
    case english = "en"
    
    var displayName: String {
        switch self {
        case .chinese:
            return "简体中文"
        case .english:
            return "English"
        }
    }
}

// 用户角色管理器
class UserRoleManager {
    // 单例模式
    static let shared = UserRoleManager()
    
    // 私有初始化方法
    private init() {
        loadUserRole()
        loadLanguageSettings()
    }
    
    // 当前用户角色
    private(set) var currentRole: UserRole = .user
    
    // 当前语言设置
    private(set) var currentLanguage: AppLanguage = .chinese
    
    // 管理员账号列表
    private let adminAccounts = ["masheal2333@gmail.com"]
    
    // 加载用户角色
    private func loadUserRole() {
        // 首先检查是否已缓存角色
        if let cachedRole = UserDefaults.standard.string(forKey: "userRole"),
           let role = UserRole(rawValue: cachedRole) {
            currentRole = role
            print("从缓存加载用户角色: \(role)")
            return
        }
        
        // 尝试获取 Apple ID
        fetchAppleAccount { [weak self] account in
            guard let self = self else { return }
            
            if let account = account, self.adminAccounts.contains(account) {
                self.currentRole = .admin
                print("设置用户角色为管理员: \(account)")
            } else {
                self.currentRole = .user
                print("设置用户角色为普通用户")
            }
            
            // 缓存角色
            UserDefaults.standard.set(self.currentRole.rawValue, forKey: "userRole")
            
            // 发送角色变更通知
            NotificationCenter.default.post(name: .userRoleDidChange, object: nil)
        }
    }
    
    // 加载语言设置
    private func loadLanguageSettings() {
        if let savedLanguage = UserDefaults.standard.string(forKey: "appLanguage"),
           let language = AppLanguage(rawValue: savedLanguage) {
            currentLanguage = language
            print("从缓存加载语言设置: \(language.displayName)")
        } else {
            // 默认根据系统语言选择
            currentLanguage = getSystemLanguage()
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "appLanguage")
            print("设置默认语言为: \(currentLanguage.displayName)")
        }
    }
    
    // 获取当前语言
    func getCurrentLanguage() -> AppLanguage {
        return currentLanguage
    }
    
    // 获取系统语言
    private func getSystemLanguage() -> AppLanguage {
        let preferredLanguage = Locale.preferredLanguages.first ?? "en"
        // 如果系统语言包含zh，则使用中文，否则使用英文
        return preferredLanguage.contains("zh") ? .chinese : .english
    }
    
    // 切换语言
    func switchLanguage(to language: AppLanguage) {
        guard language != currentLanguage else { return }
        
        currentLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: "appLanguage")
        
        // 发送语言变更通知
        NotificationCenter.default.post(name: .appLanguageDidChange, object: nil)
        print("已切换语言为: \(language.displayName)")
    }
    
    // 获取 Apple 账号
    private func fetchAppleAccount(completion: @escaping (String?) -> Void) {
        #if DEBUG
        // 在调试模式下，可以通过环境变量设置模拟账号
        if let debugAccount = ProcessInfo.processInfo.environment["DEBUG_APPLE_ACCOUNT"] {
            completion(debugAccount)
            return
        }
        #endif
        
        // 尝试从 StoreKit 获取 Apple ID
        if #available(iOS 15.0, *) {
            Task {
                do {
                    // 注释掉不存在的方法调用
                    // let status = try await StoreKit.AppStore.checkVerificationStatus()
                    
                    // 提供一个替代实现
                    // 直接返回一个默认值
                    DispatchQueue.main.async {
                        completion("unknown-user-id")
                    }
                    
                    /* 原始代码注释掉
                    switch status {
                    case .verified(let signedType):
                        if let appleAccount = signedType.appleAccountID {
                            DispatchQueue.main.async {
                                completion(appleAccount)
                            }
                        } else {
                            DispatchQueue.main.async {
                    */
                } catch {
                    print("获取 Apple 账号失败: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.fallbackToDeviceIdentifier(completion: completion)
                    }
                }
            }
        } else {
            // iOS 15 以下版本，使用备用方法
            fallbackToDeviceIdentifier(completion: completion)
        }
    }
    
    // 备用方法：使用设备标识符
    private func fallbackToDeviceIdentifier(completion: @escaping (String?) -> Void) {
        // 尝试使用 iCloud 标识符
        if let iCloudToken = FileManager.default.ubiquityIdentityToken {
            let description = iCloudToken.description
            print("使用 iCloud 标识符: \(description)")
            completion(description)
            return
        }
        
        // 如果无法获取 iCloud 标识符，使用设备名称和 UUID 组合
        let deviceName = UIDevice.current.name
        let deviceUUID = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        let combinedIdentifier = "\(deviceName)-\(deviceUUID)"
        print("使用设备标识符: \(combinedIdentifier)")
        
        // 检查是否为开发者设备
        #if DEBUG
        // 在调试模式下，可以将特定设备标识为管理员
        let knownDevices = ["Sheng-iPhone", "Sheng-iPad"]
        if knownDevices.contains(where: { deviceName.contains($0) }) {
            print("识别为开发者设备，设置为管理员")
            completion("masheal2333@gmail.com")
            return
        }
        #endif
        
        completion(combinedIdentifier)
    }
    
    // 检查是否为管理员
    func isAdmin() -> Bool {
        return currentRole == .admin
    }
    
    // 手动设置为管理员（仅用于测试）
    func setAdminForTesting() {
        #if DEBUG
        currentRole = .admin
        UserDefaults.standard.set(currentRole.rawValue, forKey: "userRole")
        NotificationCenter.default.post(name: .userRoleDidChange, object: nil)
        #endif
    }
    
    // 手动设置为普通用户（仅用于测试）
    func setUserForTesting() {
        #if DEBUG
        currentRole = .user
        UserDefaults.standard.set(currentRole.rawValue, forKey: "userRole")
        NotificationCenter.default.post(name: .userRoleDidChange, object: nil)
        #endif
    }
    
    #if DEBUG
    // 调试辅助方法：切换角色
    func toggleRole() {
        if currentRole == .admin {
            setUserForTesting()
        } else {
            setAdminForTesting()
        }
        print("已切换角色为: \(currentRole)")
    }
    #endif
}

// 通知名称扩展
extension Notification.Name {
    static let userRoleDidChange = Notification.Name("userRoleDidChange")
    static let appLanguageDidChange = Notification.Name("appLanguageDidChange")
} 