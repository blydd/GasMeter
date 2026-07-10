import Foundation
import SwiftData

enum VehicleType: String, Codable, CaseIterable {
    case car = "car"
    case motorcycle = "motorcycle"
    
    var displayName: String {
        switch self {
        case .car: return "汽车"
        case .motorcycle: return "摩托车"
        }
    }
    
    var iconName: String {
        switch self {
        case .car: return "car.fill"
        case .motorcycle: return "motorcycle.fill"
        }
    }
}

@Model
final class Vehicle {
    var id: UUID
    var name: String
    /// 原始值用于 SwiftData 持久化
    var typeRawValue: String
    var brand: String
    var model: String
    var year: Int?
    var licensePlate: String
    var fuelType: String
    var createdAt: Date
    
    /// 计算属性桥接枚举
    var type: VehicleType {
        get { VehicleType(rawValue: typeRawValue) ?? .car }
        set { typeRawValue = newValue.rawValue }
    }
    
    @Relationship(deleteRule: .cascade, inverse: \FuelRecord.vehicle)
    var records: [FuelRecord] = []
    
    init(
        name: String,
        type: VehicleType = .car,
        brand: String = "",
        model: String = "",
        year: Int? = nil,
        licensePlate: String = "",
        fuelType: String = "92#",
        createdAt: Date = Date()
    ) {
        self.id = UUID()
        self.name = name
        self.typeRawValue = type.rawValue
        self.brand = brand
        self.model = model
        self.year = year
        self.licensePlate = licensePlate
        self.fuelType = fuelType
        self.createdAt = createdAt
    }
}
