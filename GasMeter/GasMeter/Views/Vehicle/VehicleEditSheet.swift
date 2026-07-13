import SwiftUI
import SwiftData

struct VehicleEditSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var vehicle: Vehicle?  // nil = 新增模式
    
    @State private var name: String = ""
    @State private var type: VehicleType = .car
    @State private var brand: String = ""
    @State private var model: String = ""
    @State private var licensePlate: String = ""
    @State private var fuelType: String = "92#"
    @State private var tankCapacity: String = ""
    @State private var saveError: String?
    @State private var showSaveError = false
    
    private var isEditing: Bool { vehicle != nil }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    HStack {
                        Text("车辆名称")
                        Spacer()
                        TextField("例如：小白", text: $name)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("车辆类型", selection: $type) {
                        ForEach(VehicleType.allCases, id: \.self) { t in
                            Label(t.displayName, systemImage: t.iconName).tag(t)
                        }
                    }
                }
                
                Section("车辆详情") {
                    HStack {
                        Text("品牌")
                        Spacer()
                        TextField("例如：丰田", text: $brand)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("型号")
                        Spacer()
                        TextField("例如：卡罗拉", text: $model)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("车牌号")
                        Spacer()
                        TextField(type == .motorcycle ? "摩托车可选填" : "例如：京A12345", text: $licensePlate)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("常用燃油标号", selection: $fuelType) {
                        Text("92#").tag("92#")
                        Text("95#").tag("95#")
                        Text("98#").tag("98#")
                        Text("0#（柴油）").tag("0#")
                    }
                    
                    HStack {
                        Text("油箱容量")
                        Spacer()
                        TextField("选填", text: $tankCapacity)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        Text("L")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(isEditing ? "编辑车辆" : "添加车辆")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        if save() {
                            dismiss()
                        }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .fontWeight(.semibold)
                }
            }
            .alert("保存失败", isPresented: $showSaveError) {
                Button("好的", role: .cancel) {}
            } message: {
                Text(saveError ?? "未知错误")
            }
            .onAppear {
                if let v = vehicle {
                    name = v.name
                    type = v.type
                    brand = v.brand
                    model = v.model
                    licensePlate = v.licensePlate
                    fuelType = v.fuelType
                    tankCapacity = v.tankCapacity.map { String(format: "%.0f", $0) } ?? ""
                }
            }
        }
    }
    
    private func save() -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return false }
        
        if let existing = vehicle {
            existing.name = trimmed
            existing.type = type
            existing.brand = brand
            existing.model = model
            existing.licensePlate = licensePlate
            existing.fuelType = fuelType
            existing.tankCapacity = Double(tankCapacity)
        } else {
            let newVehicle = Vehicle(
                name: trimmed,
                type: type,
                brand: brand,
                model: model,
                licensePlate: licensePlate,
                fuelType: fuelType,
                tankCapacity: Double(tankCapacity)
            )
            modelContext.insert(newVehicle)
        }
        do {
            try modelContext.save()
            return true
        } catch {
            saveError = error.localizedDescription
            showSaveError = true
            return false
        }
    }
}
