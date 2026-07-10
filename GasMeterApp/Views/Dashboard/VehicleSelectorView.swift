import SwiftUI
import SwiftData

struct VehicleSelectorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(DashboardViewModel.self) private var dashboardVM
    @Environment(VehicleManagementViewModel.self) private var vehicleManagementVM
    @Query(sort: \Vehicle.createdAt) private var vehicles: [Vehicle]
    
    var body: some View {
        if vehicles.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "car.fill")
                    .font(.largeTitle)
                    .foregroundColor(.secondary.opacity(0.5))
                Text("还没有添加车辆")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                NavigationLink("去添加车辆") {
                    VehicleListView()
                }
                .font(.subheadline)
                .foregroundColor(.orange)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(vehicles) { vehicle in
                        Button {
                            dashboardVM.selectedVehicle = vehicle
                            dashboardVM.refresh(with: modelContext, allVehicles: vehicles)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: vehicle.type.iconName)
                                    .font(.caption)
                                Text(vehicle.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                dashboardVM.selectedVehicle?.id == vehicle.id
                                    ? Color.orange
                                    : Color(.systemGray5)
                            )
                            .foregroundColor(
                                dashboardVM.selectedVehicle?.id == vehicle.id
                                    ? .white
                                    : .primary
                            )
                            .clipShape(Capsule())
                            .animation(.easeInOut(duration: 0.2), value: dashboardVM.selectedVehicle?.id)
                        }
                    }
                    
                    NavigationLink {
                        VehicleListView()
                    } label: {
                        Image(systemName: "plus")
                            .font(.subheadline)
                            .padding(8)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
