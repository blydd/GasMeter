import Foundation
import Observation
import SwiftData

@Observable
final class VehicleManagementViewModel {
    var vehicles: [Vehicle] = []
    var selectedVehicle: Vehicle?
    
    func refresh(context: ModelContext) {
        let descriptor = FetchDescriptor<Vehicle>(sortBy: [SortDescriptor(\.createdAt)])
        vehicles = (try? context.fetch(descriptor)) ?? []
        if selectedVehicle == nil || !vehicles.contains(where: { $0.id == selectedVehicle?.id }) {
            selectedVehicle = vehicles.first
        }
    }
    
    func addVehicle(name: String, type: VehicleType, brand: String, model: String, licensePlate: String, fuelType: String, context: ModelContext) {
        let vehicle = Vehicle(name: name, type: type, brand: brand, model: model, licensePlate: licensePlate, fuelType: fuelType)
        context.insert(vehicle)
        do {
            try context.save()
        } catch {
            // 保存失败时不做额外处理，调用方自行处理
        }
    }
    
    func deleteVehicle(_ vehicle: Vehicle, context: ModelContext) {
        if selectedVehicle?.id == vehicle.id {
            selectedVehicle = nil
        }
        context.delete(vehicle)
        do {
            try context.save()
            // 删除后刷新列表，若之前选中的车被删除则自动选第一辆剩余车辆
            refresh(context: context)
        } catch {
            // 保存失败时不做额外处理，调用方自行刷新
        }
    }
    
    func selectVehicle(_ vehicle: Vehicle?) {
        selectedVehicle = vehicle
    }
}
