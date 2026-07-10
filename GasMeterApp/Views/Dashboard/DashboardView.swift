import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(DashboardViewModel.self) private var viewModel
    @Environment(VehicleManagementViewModel.self) private var vehicleManagementVM
    @Query(sort: \Vehicle.createdAt) private var vehicles: [Vehicle]
    
    @State private var showRecordSheet = false
    @State private var showRecordList = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 车辆选择器
                    VehicleSelectorView()
                    
                    // 仪表盘卡片
                    dashboardCard
                    
                    // 记一笔按钮
                    Button {
                        showRecordSheet = true
                    } label: {
                        Label("记一笔", systemImage: "fuelpump.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal)
                    
                    // 最近记录
                    recentRecordsSection
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("油耗记")
            .sheet(isPresented: $showRecordSheet) {
                QuickRecordSheet(onSaved: {
                    refreshData()
                })
                .presentationDetents([.medium, .large])
            }
            .onAppear { refreshData() }
            .onChange(of: vehicles.count) { refreshData() }
        }
    }
    
    private var dashboardCard: some View {
        VStack(spacing: 12) {
            HStack {
                Label("最近油耗", systemImage: "drop.fill")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(Formatters.formatFuelEfficiency(viewModel.latestEfficiency))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.orange)
                Text("L/100km")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            HStack {
                statItem(title: "最近油价", value: "¥\(Formatters.formatSimpleCurrency(viewModel.recentRecords.first?.pricePerLiter ?? 0))/L")
                Spacer()
                statItem(title: "本月油费", value: "¥\(Formatters.formatSimpleCurrency(viewModel.currentMonthCost))")
                Spacer()
                statItem(title: "总里程", value: "\(Formatters.formatOdometer(viewModel.totalKilometers)) km")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        .padding(.horizontal)
    }
    
    private var recentRecordsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("最近记录")
                    .font(.headline)
                Spacer()
                Button("查看全部") {
                    showRecordList = true
                }
                .font(.subheadline)
            }
            .padding(.horizontal)
            
            if viewModel.recentRecords.isEmpty {
                emptyStateView
            } else {
                ForEach(viewModel.recentRecords) { record in
                    RecordRowView(record: record)
                        .padding(.horizontal)
                }
            }
        }
        .navigationDestination(isPresented: $showRecordList) {
            RecordListView()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "fuelpump")
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.5))
            Text("还没有加油记录")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("点击「记一笔」开始记录吧")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private func statItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
    
    private func refreshData() {
        viewModel.refresh(with: modelContext, allVehicles: vehicles)
    }
}

#Preview {
    DashboardView()
        .modelContainer(GasMeterApp.previewContainer)
        .environment(DashboardViewModel())
        .environment(VehicleManagementViewModel())
}
