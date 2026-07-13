import SwiftUI
import SwiftData

struct VehicleListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Vehicle.createdAt) private var vehicles: [Vehicle]
    
    @State private var showAddSheet = false
    @State private var editingVehicle: Vehicle?
    @State private var showDeleteAlert = false
    @State private var deleteTarget: Vehicle?
    @State private var deleteError: String?
    @State private var showDeleteError = false
    
    var body: some View {
        Group {
            if vehicles.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "car.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary.opacity(0.4))
                    Text("还没有添加车辆")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Button {
                        showAddSheet = true
                    } label: {
                        Label("添加车辆", systemImage: "plus")
                            .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(vehicles) { vehicle in
                        Button {
                            editingVehicle = vehicle
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: vehicle.type.iconName)
                                    .font(.title2)
                                    .foregroundColor(.orange)
                                    .frame(width: 36, height: 36)
                                    .background(Color.orange.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(vehicle.name)
                                        .font(.headline)
                                    HStack(spacing: 6) {
                                        if !vehicle.brand.isEmpty {
                                            Text(vehicle.brand)
                                                .font(.caption)
                                        }
                                        if !vehicle.model.isEmpty {
                                            Text(vehicle.model)
                                                .font(.caption)
                                        }
                                        if !vehicle.licensePlate.isEmpty {
                                            Text(vehicle.licensePlate)
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Text(vehicle.fuelType)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(.systemGray5))
                                    .clipShape(Capsule())
                            }
                            .padding(.vertical, 4)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                deleteTarget = vehicle
                                showDeleteAlert = true
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("车辆管理")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            VehicleEditSheet(vehicle: nil)
        }
        .sheet(item: $editingVehicle) { vehicle in
            VehicleEditSheet(vehicle: vehicle)
        }
        .alert("确认删除", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                if let target = deleteTarget {
                    modelContext.delete(target)
                    do {
                        try modelContext.save()
                    } catch {
                        deleteError = error.localizedDescription
                        showDeleteError = true
                    }
                }
            }
        } message: {
            Text("删除车辆将同时删除其所有加油记录，此操作不可恢复。")
        }
        .alert("操作失败", isPresented: $showDeleteError) {
            Button("好的", role: .cancel) {}
        } message: {
            Text(deleteError ?? "未知错误")
        }
    }
}
