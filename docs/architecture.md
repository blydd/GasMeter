# GasMeter 架构设计

## 架构概览
- **模式**: MVVM（iOS 17 原生：@Model + @Observable + @Environment(\.modelContext)）
- **UI**: SwiftUI
- **持久化**: SwiftData（ModelContainer 在 GasMeterApp 入口统一注入）
- **图表**: Swift Charts
- **CSV**: 自实现 CSVService（纯结构体，零第三方依赖）
- **依赖**: 全部 iOS 17 SDK 原生能力

## 文件规划（25 个 Swift 文件，6 模块）

### Models (2)
- GasMeterApp/Models/Vehicle.swift
- GasMeterApp/Models/FuelRecord.swift

### ViewModels (4)
- GasMeterApp/ViewModels/DashboardViewModel.swift
- GasMeterApp/ViewModels/RecordFormViewModel.swift
- GasMeterApp/ViewModels/StatisticsViewModel.swift
- GasMeterApp/ViewModels/VehicleManagementViewModel.swift

### Views (15)
- GasMeterApp/Views/ContentView.swift (TabBar)
- GasMeterApp/Views/Dashboard/DashboardView.swift
- GasMeterApp/Views/Dashboard/VehicleSelectorView.swift
- GasMeterApp/Views/Dashboard/QuickRecordSheet.swift
- GasMeterApp/Views/Dashboard/RecordRowView.swift
- GasMeterApp/Views/Records/RecordListView.swift
- GasMeterApp/Views/Records/RecordEditSheet.swift
- GasMeterApp/Views/Statistics/StatisticsView.swift
- GasMeterApp/Views/Statistics/ChartViews.swift
- GasMeterApp/Views/Settings/SettingsView.swift
- GasMeterApp/Views/Vehicle/VehicleListView.swift
- GasMeterApp/Views/Vehicle/VehicleEditSheet.swift
- GasMeterApp/Views/CSV/CSVExportView.swift
- GasMeterApp/Views/CSV/CSVImportView.swift
- GasMeterApp/Views/Components/ (共用组件)

### Services (2)
- GasMeterApp/Services/FuelCalculationService.swift
- GasMeterApp/Services/CSVService.swift

### Utilities (2)
- GasMeterApp/Utilities/Formatters.swift
- GasMeterApp/Utilities/DateExtensions.swift

### App 入口 (1)
- GasMeterApp/GasMeterApp.swift

## 任务拆分（5 个任务）

| 任务 | 文件数 | 依赖 | 内容 |
|------|--------|------|------|
| T01 | 5 | 无 | GasMeterApp, Vehicle, FuelRecord, Formatters |
| T02 | 6 | T01 | FuelCalculationService, CSVService, 4 个 ViewModel |
| T03 | 8 | T02 | Dashboard, QuickRecord, Records, TabBar, Components |
| T04 | 6 | T02 | Statistics+Charts, Settings, VehicleManagement |
| T05 | 3 新+3 改 | T03,T04 | CSVExport/Import, 全局联调 |

- T03 和 T04 可并行开发

## 关键设计决策
1. 油耗计算：FuelCalculationService 纯函数 → 过滤 isFullTank=true → 按里程排序 → 相邻配对 → fuelAmount/distance×100
2. CSV：UTF-8 with BOM，自解析，导入时字段映射+校验→批量写入
3. ViewModel：iOS 17 @Observable，不持有 ModelContext（由 View 传入）
4. P2 预留：FuelCalculationService 可扩展智能合并、Vehicle 预留 fuelAlertThreshold、CSVService 可扩展冲突检测

## 已确认假设
1. 多车辆切换时油耗计算不缓存，每次重新计算
2. CSV 导入直接追加，P2 再做冲突检测
3. 摩托车车牌允许空字符串
