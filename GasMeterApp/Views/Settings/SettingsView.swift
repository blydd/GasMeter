import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(DashboardViewModel.self) private var dashboardVM
    @Environment(StatisticsViewModel.self) private var statisticsVM
    @Environment(VehicleManagementViewModel.self) private var vehicleManagementVM
    @Query(sort: \Vehicle.createdAt) private var vehicles: [Vehicle]
    
    @State private var showExport = false
    @State private var showImport = false
    @State private var showClearAlert = false
    @State private var importResult: String?
    @State private var showImportResult = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("用户信息") {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                        VStack(alignment: .leading) {
                            Text("油耗记用户")
                                .font(.headline)
                            Text("\(vehicles.count) 辆车")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section("数据管理") {
                    Button {
                        showExport = true
                    } label: {
                        Label("导出全部数据 (CSV)", systemImage: "square.and.arrow.up")
                    }
                    
                    Button {
                        showImport = true
                    } label: {
                        Label("导入数据 (CSV)", systemImage: "square.and.arrow.down")
                    }
                    
                    Button(role: .destructive) {
                        showClearAlert = true
                    } label: {
                        Label("清空全部数据", systemImage: "trash")
                    }
                }
                
                Section("车辆管理") {
                    NavigationLink {
                        VehicleListView()
                    } label: {
                        Label("管理我的车辆", systemImage: "car.fill")
                    }
                }
                
                Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("技术栈")
                        Spacer()
                        Text("SwiftUI + SwiftData")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("设置")
            .sheet(isPresented: $showExport) {
                CSVExportView()
            }
            .sheet(isPresented: $showImport) {
                CSVImportView()
            }
            .alert("清空全部数据", isPresented: $showClearAlert) {
                Button("取消", role: .cancel) {}
                Button("清空", role: .destructive) {
                    clearAllData()
                }
            } message: {
                Text("此操作将删除所有车辆和加油记录，且无法恢复。建议先导出数据备份。")
            }
        }
    }
    
    private func clearAllData() {
        for vehicle in vehicles {
            modelContext.delete(vehicle)
        }
        do {
            try modelContext.save()
            // 刷新所有 ViewModel
            dashboardVM.reset()
            statisticsVM.reset()
            vehicleManagementVM.refresh(context: modelContext)
        } catch {
            // 保存失败：CoreData 已标记删除但未持久化，下次启动会回滚
        }
    }
}
