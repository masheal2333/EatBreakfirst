//
//  LanguageSettingsView.swift
//  EatBreakFirst
//
//  Created on 3/9/25.
//

import SwiftUI

struct LanguageSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedLanguage: AppLanguage
    
    init() {
        // 初始化时获取当前语言设置
        _selectedLanguage = State(initialValue: UserRoleManager.shared.getCurrentLanguage())
    }
    
    var body: some View {
        NavigationView {
            List {
                // 语言选择说明
                Section(header: Text(L(.languageSettings)), footer: Text(L(.languageSettingsNote))) {
                    // 空视图，只显示说明文本
                    EmptyView()
                }
                
                // 手动选择语言
                Section(header: Text(L(.language))) {
                    ForEach(AppLanguage.allCases, id: \.self) { language in
                        Button(action: {
                            selectedLanguage = language
                            UserRoleManager.shared.switchLanguage(to: language)
                            
                            // 关闭设置页面
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }) {
                            HStack {
                                Text(language.displayName)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if selectedLanguage == language {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                
                Section(footer: Text(L(.appVersion))) {
                    EmptyView()
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(L(.switchLanguage))
            .navigationBarItems(trailing: Button(L(.cancel)) {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

#Preview {
    LanguageSettingsView()
} 