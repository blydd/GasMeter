import SwiftUI
import SwiftData

@main
struct GasMeterApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([Vehicle.self, FuelRecord.self])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("无法创建 ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
    
    // Preview 辅助容器（内存模式，不污染磁盘数据）
    static var previewContainer: ModelContainer = {
        let schema = Schema([Vehicle.self, FuelRecord.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        // 注入示例数据
        let car = Vehicle(name: "小白", type: .car, brand: "丰田", model: "卡罗拉", licensePlate: "京A12345", fuelType: "92#")
        let moto = Vehicle(name: "小钢炮", type: .motorcycle, brand: "春风", model: "250SR", licensePlate: "", fuelType: "92#")
        container.mainContext.insert(car)
        container.mainContext.insert(moto)
        let records: [FuelRecord] = [
            FuelRecord(date: Calendar.current.date(byAdding: .day, value: -7, to: Date())!, odometer: 52000, fuelAmount: 42.5, pricePerLiter: 7.85, isFullTank: true, fuelType: "92#", notes: ""),
            FuelRecord(date: Calendar.current.date(byAdding: .day, value: -20, to: Date())!, odometer: 51480, fuelAmount: 38.0, pricePerLiter: 7.85, isFullTank: true, fuelType: "92#", notes: "高速长途"),
        ]
        for r in records { r.vehicle = car; container.mainContext.insert(r) }
        return container
    }()
}
