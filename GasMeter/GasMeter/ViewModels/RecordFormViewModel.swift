import Foundation
import Observation
import SwiftData

@Observable
final class RecordFormViewModel {
    // 表单字段
    var date: Date = Date()
    var odometer: String = ""
    var fuelAmount: String = ""
    var pricePerLiter: String = ""
    var isFullTank: Bool = true
    var fuelType: String = "92#"
    var notes: String = ""
    
    // 编辑模式
    var editingRecord: FuelRecord?
    var isEditing: Bool { editingRecord != nil }
    
    var totalCost: Double {
        let amount = Double(fuelAmount) ?? 0
        let price = Double(pricePerLiter) ?? 0
        return amount * price
    }
    
    /// 表单是否有效（三个核心字段都有值且合法）
    var isValid: Bool {
        guard let odo = Double(odometer), odo > 0 else { return false }
        guard let amount = Double(fuelAmount), amount > 0 else { return false }
        guard let price = Double(pricePerLiter), price > 0 else { return false }
        return true
    }
    
    /// 填充编辑模式的数据
    func loadForEdit(_ record: FuelRecord) {
        editingRecord = record
        date = record.date
        odometer = String(record.odometer)
        fuelAmount = String(record.fuelAmount)
        pricePerLiter = String(record.pricePerLiter)
        isFullTank = record.isFullTank
        fuelType = record.fuelType
        notes = record.notes
    }
    
    /// 保存（新增或更新），失败时抛出错误
    func save(context: ModelContext, vehicle: Vehicle) throws {
        if let existing = editingRecord {
            // 编辑模式
            existing.date = date
            existing.odometer = Double(odometer) ?? 0
            existing.fuelAmount = Double(fuelAmount) ?? 0
            existing.pricePerLiter = Double(pricePerLiter) ?? 0
            existing.isFullTank = isFullTank
            existing.fuelType = fuelType
            existing.notes = notes
        } else {
            // 新增模式
            let record = FuelRecord(
                date: date,
                odometer: Double(odometer) ?? 0,
                fuelAmount: Double(fuelAmount) ?? 0,
                pricePerLiter: Double(pricePerLiter) ?? 0,
                isFullTank: isFullTank,
                fuelType: fuelType,
                notes: notes
            )
            record.vehicle = vehicle
            context.insert(record)
        }
        try context.save()
    }
    
    /// 删除记录，失败时抛出错误
    func delete(context: ModelContext) throws {
        guard let record = editingRecord else { return }
        context.delete(record)
        try context.save()
    }
    
    /// 重置表单
    func reset() {
        editingRecord = nil
        date = Date()
        odometer = ""
        fuelAmount = ""
        pricePerLiter = ""
        isFullTank = true
        fuelType = "92#"
        notes = ""
    }
}
