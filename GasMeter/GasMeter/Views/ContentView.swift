import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Vehicle.createdAt) private var vehicles: [Vehicle]
    
    @State private var dashboardVM = DashboardViewModel()
    @State private var statisticsVM = StatisticsViewModel()
    @State private var vehicleManagementVM = VehicleManagementViewModel()
    @State private var selectedTab: Tab = .dashboard
    
    enum Tab: String, CaseIterable {
        case dashboard = "首页"
        case statistics = "统计"
        case settings = "设置"
        
        var icon: String {
            switch self {
            case .dashboard: return "gauge.with.dots.needle.33percent"
            case .statistics: return "chart.bar.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem { Label(Tab.dashboard.rawValue, systemImage: Tab.dashboard.icon) }
                .tag(Tab.dashboard)
            
            StatisticsView()
                .tabItem { Label(Tab.statistics.rawValue, systemImage: Tab.statistics.icon) }
                .tag(Tab.statistics)
            
            SettingsView()
                .tabItem { Label(Tab.settings.rawValue, systemImage: Tab.settings.icon) }
                .tag(Tab.settings)
        }
        .tint(.orange)
        .onAppear {
            vehicleManagementVM.refresh(context: modelContext)
            dashboardVM.refresh(with: modelContext, allVehicles: vehicles)
        }
        .onChange(of: vehicles.count) {
            vehicleManagementVM.refresh(context: modelContext)
            dashboardVM.refresh(with: modelContext, allVehicles: vehicles)
        }
        .environment(dashboardVM)
        .environment(statisticsVM)
        .environment(vehicleManagementVM)
    }
}

#Preview {
    ContentView()
        .modelContainer(GasMeterApp.previewContainer)
}
