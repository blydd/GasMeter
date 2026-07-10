import Foundation
import SwiftData

@Model
final class FuelRecord {
    var id: UUID
    var date: Date
    var odometer: Double
    var fuelAmount: Double
    var pricePerLiter: Double
    var isFullTank: Bool
    var fuelType: String
    var notes: String
    var createdAt: Date
    
    @Relationship(inverse: \Vehicle.records)
    var vehicle: Vehicle?
    
    /// 总金额 — @Transient 不持久化，始终实时计算
    @Transient
    var totalCost: Double {
        fuelAmount * pricePerLiter
    }
    
    init(
        date: Date = Date(),
        odometer: Double,
        fuelAmount: Double,
        pricePerLiter: Double,
        isFullTank: Bool = true,
        fuelType: String = "92#",
        notes: String = "",
        createdAt: Date = Date()
    ) {
        self.id = UUID()
        self.date = date
        self.odometer = odometer
        self.fuelAmount = fuelAmount
        self.pricePerLiter = pricePerLiter
        self.isFullTank = isFullTank
        self.fuelType = fuelType
        self.notes = notes
        self.createdAt = createdAt
    }
}
