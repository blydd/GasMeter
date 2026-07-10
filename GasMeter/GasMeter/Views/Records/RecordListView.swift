import SwiftUI
import SwiftData

struct RecordListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(DashboardViewModel.self) private var dashboardVM
    
    @State private var editTarget: FuelRecord?
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    @State private var deleteTarget: FuelRecord?
    @State private var deleteError: String?
    @State private var showDeleteError = false
    
    private var records: [FuelRecord] {
        guard let vehicle = dashboardVM.selectedVehicle else { return [] }
        return (vehicle.records).sorted { $0.date > $1.date }
    }
    
    var body: some View {
        Group {
            if records.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("暂无记录")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(records) { record in
                        Button {
                            editTarget = record
                            showEditSheet = true
                        } label: {
                            RecordRowView(record: record)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                deleteTarget = record
                                showDeleteAlert = true
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("加油记录")
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
            Text("删除后无法恢复，确定要删除这条记录吗？")
        }
        .alert("操作失败", isPresented: $showDeleteError) {
            Button("好的", role: .cancel) {}
        } message: {
            Text(deleteError ?? "未知错误")
        }
        .sheet(isPresented: $showEditSheet) {
            // onDismiss 时不刷新 (sheet 内部的 save 已处理)
            if let record = editTarget {
                RecordEditSheet(record: record)
                    .presentationDetents([.medium, .large])
            }
        }
    }
}
