import Foundation

extension Date {
    /// 当月第一天 00:00:00
    var startOfMonth: Date {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: self)
        return cal.date(from: comps) ?? self
    }
    
    /// 当月最后一天 23:59:59
    var endOfMonth: Date {
        let cal = Calendar.current
        var comps = DateComponents()
        comps.month = 1
        comps.second = -1
        return cal.date(byAdding: comps, to: startOfMonth) ?? self
    }
    
    /// 年份和月份标识符，如 "2025-03"
    var yearMonthIdentifier: String {
        let cal = Calendar.current
        let year = cal.component(.year, from: self)
        let month = cal.component(.month, from: self)
        return String(format: "%04d-%02d", year, month)
    }
    
    /// 获取最近 N 个月的所有月份标识符
    static func lastNMonths(_ n: Int) -> [String] {
        let cal = Calendar.current
        var result: [String] = []
        var date = Date()
        for _ in 0..<n {
            let year = cal.component(.year, from: date)
            let month = cal.component(.month, from: date)
            result.insert(String(format: "%04d-%02d", year, month), at: 0)
            date = cal.date(byAdding: .month, value: -1, to: date) ?? date
        }
        return result
    }
}
