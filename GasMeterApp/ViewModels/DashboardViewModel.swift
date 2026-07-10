import Foundation
import Observation
import SwiftData

@Observable
final class DashboardViewModel {
    var selectedVehicle: Vehicle?
    var latestEfficiency: Double?
    var currentMonthCost: Double = 0
    var totalKilometers: Double = 0
    var recentRecords: [FuelRecord] = []
    
    func refresh(with context: ModelContext, allVehicles: [Vehicle]) {
        guard let vehicle = selectedVehicle ?? allVehicles.first else {
            reset()
            return
        }
        selectedVehicle = vehicle
        
        let records = (vehicle.records ?? []).sorted { $0.date > $1.date }
        latestEfficiency = FuelCalculationService.latestFuelEfficiency(records: records)
        currentMonthCost = FuelCalculationService.currentMonthTotalCost(records: records)
        let sortedByOdo = records.sorted { $0.odometer < $1.odometer }
        totalKilometers = sortedByOdo.last?.odometer ?? 0
        recentRecords = Array(records.prefix(5))
    }
    
    func reset() {
        selectedVehicle = nil
        latestEfficiency = nil
        currentMonthCost = 0
        totalKilometers = 0
        recentRecords = []
    }
}
