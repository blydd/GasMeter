import Foundation

/// 油耗计算服务 — 纯函数，无状态
struct FuelCalculationService {
    
    /// 计算最近一次百公里油耗（L/100km）
    /// 规则：筛选 isFullTank==true → 按 odometer 升序 → 取最后两条配对计算
    static func latestFuelEfficiency(records: [FuelRecord]) -> Double? {
        let fullTankRecords = records
            .filter { $0.isFullTank }
            .sorted { $0.odometer < $1.odometer }
        guard fullTankRecords.count >= 2 else { return nil }
        let last = fullTankRecords[fullTankRecords.count - 1]
        let prev = fullTankRecords[fullTankRecords.count - 2]
        let distance = last.odometer - prev.odometer
        guard distance > 0 else { return nil }
        return last.fuelAmount / distance * 100
    }
    
    /// 所有相邻加满区间的油耗列表
    static func allEfficiencies(records: [FuelRecord]) -> [(date: Date, efficiency: Double)] {
        let fullTankRecords = records
            .filter { $0.isFullTank }
            .sorted { $0.odometer < $1.odometer }
        guard fullTankRecords.count >= 2 else { return [] }
        var results: [(Date, Double)] = []
        for i in 1..<fullTankRecords.count {
            let curr = fullTankRecords[i]
            let prev = fullTankRecords[i - 1]
            let distance = curr.odometer - prev.odometer
            if distance > 0 {
                let eff = curr.fuelAmount / distance * 100
                results.append((curr.date, eff))
            }
        }
        return results
    }
    
    /// 月度平均油耗（按记录日期分组）
    static func monthlyAverageEfficiency(records: [FuelRecord]) -> [String: Double] {
        let efficiencies = allEfficiencies(records: records)
        var grouped: [String: [Double]] = [:]
        for (date, eff) in efficiencies {
            let key = date.yearMonthIdentifier
            grouped[key, default: []].append(eff)
        }
        return grouped.mapValues { values in
            values.reduce(0, +) / Double(values.count)
        }
    }
    
    /// 月度总油费
    static func monthlyTotalCost(records: [FuelRecord]) -> [String: Double] {
        var result: [String: Double] = [:]
        for record in records {
            let key = record.date.yearMonthIdentifier
            result[key, default: 0] += record.totalCost
        }
        return result
    }
    
    /// 本月总油费
    static func currentMonthTotalCost(records: [FuelRecord]) -> Double {
        let start = Date().startOfMonth
        let end = Date().endOfMonth
        return records
            .filter { $0.date >= start && $0.date <= end }
            .reduce(0) { $0 + $1.totalCost }
    }
    
    /// 累计统计
    struct CumulativeStats {
        let totalOdometer: Double
        let totalCost: Double
        let totalFuelAmount: Double
        let averageEfficiency: Double?
    }
    
    static func cumulativeStats(records: [FuelRecord]) -> CumulativeStats {
        let sorted = records.sorted { $0.odometer < $1.odometer }
        let totalOdometer = sorted.last?.odometer ?? 0
        let totalCost = records.reduce(0) { $0 + $1.totalCost }
        let totalFuelAmount = records.reduce(0) { $0 + $1.fuelAmount }
        var avgEff: Double?
        if let last = sorted.last, let first = sorted.first, last.odometer > first.odometer {
            let totalDist = last.odometer - first.odometer
            if totalDist > 0 {
                avgEff = totalFuelAmount / totalDist * 100
            }
        }
        return CumulativeStats(
            totalOdometer: totalOdometer,
            totalCost: totalCost,
            totalFuelAmount: totalFuelAmount,
            averageEfficiency: avgEff
        )
    }
}
