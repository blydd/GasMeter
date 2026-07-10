import SwiftUI
import SwiftData

struct StatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(DashboardViewModel.self) private var dashboardVM
    @Environment(StatisticsViewModel.self) private var statisticsVM
    @Query(sort: \Vehicle.createdAt) private var vehicles: [Vehicle]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if dashboardVM.selectedVehicle == nil && vehicles.isEmpty {
                    emptyStateView
                } else {
                    VStack(spacing: 20) {
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
            .onChange(of: dashboardVM.selectedVehicle?.id) { refresh() }
            .onChange(of: dashboardVM.recentRecords.count) { refresh() }
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
        if let vehicle = dashboardVM.selectedVehicle {
            records = vehicle.records
        } else if let first = vehicles.first {
            records = first.records
        } else {
            records = []
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
