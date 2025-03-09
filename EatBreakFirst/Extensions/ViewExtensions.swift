import SwiftUI

// 为View添加兼容性扩展，处理iOS 16和iOS 17的onChange差异
extension View {
    @ViewBuilder
    func onChangeCompat<Value: Equatable>(of value: Value, perform action: @escaping (Value) -> Void) -> some View {
        if #available(iOS 17.0, *) {
            self.onChange(of: value) { oldValue, newValue in
                action(newValue)
            }
        } else {
            self.onChange(of: value) { newValue in
                action(newValue)
            }
        }
    }
} 