import Foundation
import Observation

@Observable
final class StatisticsViewModel {
    var monthlyEfficiencyData: [(month: String, value: Double)] = []
    var monthlyCostData: [(month: String, value: Double)] = []
    var cumulativeStats: FuelCalculationService.CumulativeStats?
    
    func refresh(records: [FuelRecord]) {
        let efficiencyMap = FuelCalculationService.monthlyAverageEfficiency(records: records)
        let costMap = FuelCalculationService.monthlyTotalCost(records: records)
        let months = Date.lastNMonths(6)
        
        monthlyEfficiencyData = months.map { m in
            (month: m, value: efficiencyMap[m] ?? 0)
        }
        monthlyCostData = months.map { m in
            (month: m, value: costMap[m] ?? 0)
        }
        cumulativeStats = FuelCalculationService.cumulativeStats(records: records)
    }
    
    func reset() {
        monthlyEfficiencyData = []
        monthlyCostData = []
        cumulativeStats = nil
    }
}
