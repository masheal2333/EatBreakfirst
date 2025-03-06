//
//  StatsView.swift
//  EatBreakFirst
//
//  Created on 3/6/25.
//

import SwiftUI

// Stats View
public struct StatsView: View {
    let stats: BreakfastStats
    @Environment(\.dismiss) private var dismiss
    
    public var body: some View {
        NavigationView {
            List {
                Section(header: Text("统计数据")) {
                    StatRow(title: "已记录天数", value: "\(stats.totalDaysTracked) 天")
                    StatRow(title: "早餐天数", value: "\(stats.daysEaten) 天")
                    StatRow(title: "未吃早餐", value: "\(stats.daysSkipped) 天")
                }
                
                Section(header: Text("连续记录")) {
                    StatRow(title: "当前连续", value: "\(stats.currentStreak) 天")
                    StatRow(title: "最长连续", value: "\(stats.longestStreak) 天")
                }
                
                Section(header: Text("完成率")) {
                    VStack(alignment: .leading) {
                        Text("\(Int(stats.completionRate))%")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.accentColor)
                        
                        ProgressView(value: stats.completionRate, total: 100)
                            .progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("早餐统计")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
}

public struct StatRow: View {
    let title: String
    let value: String
    
    public var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}
