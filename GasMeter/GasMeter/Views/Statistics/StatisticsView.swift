import SwiftUI
import SwiftData

/// 统计页车辆切页模式
enum StatisticsTab: Hashable {
    case all
    case vehicle(UUID)
}

struct StatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(DashboardViewModel.self) private var dashboardVM
    @Environment(StatisticsViewModel.self) private var statisticsVM
    @Query(sort: \Vehicle.createdAt) private var vehicles: [Vehicle]
    
    @State private var selectedTab: StatisticsTab = .all
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if vehicles.isEmpty {
                    emptyStateView
                } else {
                    VStack(spacing: 20) {
                        // 车辆切页选择器（仅多车时显示）
                        if vehicles.count > 1 {
                            vehicleTabPicker
                        }
                        
                        // 累计统计卡片
                        cumulativeStatsCard
                        
                        // 月度油耗趋势
                        chartSection(title: "月度油耗趋势 (L/100km)", subtitle: "近6个月") {
                            MonthlyEfficiencyChart(data: statisticsVM.monthlyEfficiencyData)
                        }
                        
                        // 月度油费
                        chartSection(title: "月度油费 (元)", subtitle: "近6个月") {
                            MonthlyCostChart(data: statisticsVM.monthlyCostData)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("统计")
            .onAppear { refresh() }
            .onChange(of: selectedTab) { refresh() }
            .onChange(of: vehicles.flatMap { $0.records }.count) { refresh() }
            .onChange(of: vehicles.count) { oldCount, newCount in
                // 车辆被删除时重置到全部
                if case .vehicle(let id) = selectedTab, !vehicles.contains(where: { $0.id == id }) {
                    selectedTab = .all
                }
                refresh()
            }
        }
    }
    
    @ViewBuilder
    private var vehicleTabPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                tabButton(title: "全部", isSelected: selectedTab == .all) {
                    selectedTab = .all
                }
                ForEach(vehicles) { vehicle in
                    tabButton(title: vehicle.name, isSelected: selectedTab == .vehicle(vehicle.id)) {
                        selectedTab = .vehicle(vehicle.id)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func tabButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.orange : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
    
    private var cumulativeStatsCard: some View {
        let stats = statisticsVM.cumulativeStats
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statCell(title: "总里程", value: Formatters.formatOdometer(stats?.totalOdometer ?? 0), unit: "km", icon: "speedometer", color: .blue)
            statCell(title: "总油费", value: Formatters.formatSimpleCurrency(stats?.totalCost ?? 0), unit: "元", icon: "yensign.circle.fill", color: .orange)
            statCell(title: "总油量", value: Formatters.formatFuelAmount(stats?.totalFuelAmount ?? 0), unit: "L", icon: "drop.fill", color: .teal)
            statCell(title: "平均油耗", value: Formatters.formatFuelEfficiency(stats?.averageEfficiency), unit: "L/100km", icon: "gauge.with.dots.needle.33percent", color: .purple)
        }
        .padding(.horizontal)
    }
    
    private func statCell(title: String, value: String, unit: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .fontDesign(.rounded)
            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func chartSection(title: String, subtitle: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            content()
                .frame(height: 220)
                .padding(.horizontal, 8)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 50))
                .foregroundColor(.secondary.opacity(0.4))
            Text("暂无统计数据")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("添加车辆并记录加油数据后\n将在此显示统计图表")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 100)
    }
    
    private func refresh() {
        let records: [FuelRecord]
        switch selectedTab {
        case .all:
            records = vehicles.flatMap { $0.records }
        case .vehicle(let id):
            records = vehicles.first(where: { $0.id == id })?.records ?? []
        }
        statisticsVM.refresh(records: records)
    }
}

#Preview {
    StatisticsView()
        .modelContainer(GasMeterApp.previewContainer)
        .environment(DashboardViewModel())
        .environment(StatisticsViewModel())
}
