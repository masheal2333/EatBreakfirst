//
//  BreakfastModels.swift
//  EatBreakFirst
//
//  Created on 3/6/25.
//

import Foundation
import SwiftUI

// Codable struct for breakfast records
struct BreakfastRecord: Codable {
    let date: TimeInterval
    let hasEaten: Bool
}

// Achievement model
struct Achievement: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
    let requirement: Int
    var isUnlocked: Bool = false
}

// Statistics model
struct BreakfastStats {
    let totalDaysTracked: Int
    let daysEaten: Int
    let daysSkipped: Int
    let currentStreak: Int
    let longestStreak: Int
    let completionRate: Double
}


