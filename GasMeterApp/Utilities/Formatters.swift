import Foundation

/// 全局格式化工具
enum Formatters {
    /// 日期：yyyy-MM-dd
    static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "zh_CN")
        return f
    }()
    
    /// 短日期：MM/dd
    static let shortDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MM/dd"
        f.locale = Locale(identifier: "zh_CN")
        return f
    }()
    
    /// 月份：yyyy年M月
    static let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy年M月"
        f.locale = Locale(identifier: "zh_CN")
        return f
    }()
    
    /// 金额：¥1,280.00
    static let currencyFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = Locale(identifier: "zh_CN")
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f
    }()
    
    /// 油耗：6.8 格式
    static func formatFuelEfficiency(_ value: Double?) -> String {
        guard let v = value, v.isFinite, v > 0 else { return "--" }
        return String(format: "%.1f", v)
    }
    
    /// 里程：15,680
    static func formatOdometer(_ value: Double) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.locale = Locale(identifier: "zh_CN")
        return nf.string(from: NSNumber(value: value)) ?? "\(value)"
    }
    
    /// 油量：42.5 格式
    static func formatFuelAmount(_ value: Double) -> String {
        return String(format: "%.1f", value)
    }
    
    /// 金额简单格式化（不含¥符号）：1,280.00
    static func formatSimpleCurrency(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.locale = Locale(identifier: "zh_CN")
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    }
    
    /// CSV 日期：yyyy-MM-dd
    static var csvDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
}
