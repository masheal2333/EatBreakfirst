# 小组件与应用数据状态一致性策略

## 问题描述

在 iOS 应用与小组件之间可能出现数据状态不一致的情况，例如：
- 应用中显示已吃早餐，但小组件显示未吃或未记录
- 应用中显示未吃早餐，但小组件显示已吃或未记录
- 应用中清除了记录，但小组件仍显示旧状态

这种不一致会导致用户体验混乱，降低应用的可信度。

## 解决策略：以应用数据为准

我们采用"以应用数据为准"的策略，确保小组件始终显示与应用一致的数据状态。具体实现如下：

### 1. 应用端实现

#### 1.1 强制更新机制

创建 `forceUpdateWidget()` 方法，使用多次梯度式更新确保小组件获取最新数据：

```swift
private func forceUpdateWidget() {
    // 立即更新一次
    WidgetCenter.shared.reloadAllTimelines()
    
    // 使用多次延迟更新，确保小组件能够获取到最新数据
    let delayTimes = [0.3, 0.8, 2.0] // 多个时间点进行更新
    
    for (index, delay) in delayTimes.enumerated() {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
```

#### 1.2 数据一致性检查方法

添加 `ensureWidgetDataConsistency()` 方法，专门用于确保数据一致性：

```swift
func ensureWidgetDataConsistency() {
    // 强制同步到磁盘
    BreakfastTracker.shared.synchronize()
    
    // 强制更新小组件
    DispatchQueue.main.async {
        self.forceUpdateWidget()
    }
}
```

#### 1.3 关键时刻触发一致性检查

在以下关键时刻触发数据一致性检查：

1. **应用启动时**：
```swift
.onAppear {
    breakfastTracker.ensureWidgetDataConsistency()
}
```

2. **应用进入前台时**：
```swift
@objc private func refreshDataFromSharedStorage() {
    loadRecords()
    calculateStreak()
    objectWillChange.send()
    
    // 强制更新小组件，确保数据一致性
    DispatchQueue.main.async {
        self.forceUpdateWidget()
    }
}
```

3. **数据变更操作后**：
   - 记录早餐状态后
   - 清除今天记录后
   - 修改设置后

### 2. 小组件端实现

#### 2.1 数据一致性检查

在小组件的 `Provider` 类中添加 `ensureDataConsistency()` 方法：

```swift
private func ensureDataConsistency() {
    // 强制同步 UserDefaults
    BreakfastTracker.shared.synchronize()
    
    // 获取当前小组件显示的状态
    let currentWidgetStatus = getTodayBreakfastStatus()
    
    // 主动请求更新小组件
    WidgetCenter.shared.reloadAllTimelines()
}
```

#### 2.2 时间线生成前检查一致性

在生成时间线前调用一致性检查方法：

```swift
func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
    // 执行数据一致性检查，确保小组件数据与应用数据一致
    ensureDataConsistency()
    
    // 获取早餐状态和连续天数
    let hasEatenBreakfast = getTodayBreakfastStatus()
    let streak = calculateStreak()
    
    // ... 创建时间线条目和设置更新策略
}
```

#### 2.3 动态更新频率

根据当前状态动态调整自动更新频率：
- 未记录状态：每 5 分钟检查一次
- 已记录状态：每 15 分钟检查一次

### 3. 共享存储优化

#### 3.1 强制同步

在所有读写操作中使用 `synchronize()` 方法确保数据立即写入磁盘：

```swift
BreakfastTracker.shared.synchronize()
```

#### 3.2 统一键名

确保应用和小组件使用完全相同的键名访问共享数据：

```swift
let userDefaultsKey = "breakfastRecords"
```

#### 3.3 改进日期比较

使用 `calendar.isDate(_:inSameDayAs:)` 方法进行日期比较，避免时间戳精度问题：

```swift
let isSameDay = calendar.isDate(recordDay, inSameDayAs: today)
```

## 数据流程图

```
┌─────────────┐      ┌───────────────┐      ┌─────────────┐
│             │      │               │      │             │
│    应用     │─────▶│  共享存储     │◀─────│   小组件    │
│             │      │ (UserDefaults)│      │             │
└─────┬───────┘      └───────────────┘      └──────┬──────┘
      │                                            │
      │                                            │
      ▼                                            ▼
┌─────────────┐                           ┌─────────────┐
│ 数据变更    │                           │ 时间线生成  │
│ 触发一致性  │                           │ 触发一致性  │
│ 检查        │                           │ 检查        │
└─────────────┘                           └─────────────┘
```

## 总结

通过这种多层次的数据一致性策略，我们确保了小组件始终显示与应用一致的数据状态，以应用数据为准。关键点包括：

1. **主动触发**：在应用启动、进入前台和数据变更时主动触发一致性检查
2. **多次更新**：使用梯度式多次更新机制确保小组件获取最新数据
3. **双向检查**：应用和小组件都实现了数据一致性检查机制
4. **强制同步**：所有读写操作都强制同步到磁盘
5. **动态频率**：根据状态动态调整自动更新频率

这种策略有效解决了小组件与应用数据状态不一致的问题，提升了用户体验。 