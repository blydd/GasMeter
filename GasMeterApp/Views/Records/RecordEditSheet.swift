import SwiftUI
import SwiftData

struct RecordEditSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(DashboardViewModel.self) private var dashboardVM
    @Environment(\.dismiss) private var dismiss
    
    let record: FuelRecord
    @State private var formVM = RecordFormViewModel()
    @State private var showDeleteConfirm = false
    @State private var saveError: String?
    @State private var showSaveError = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("加油信息") {
                    DatePicker("日期", selection: $formVM.date, displayedComponents: .date)
                    
                    HStack {
                        Text("里程表")
                        Spacer()
                        TextField("0", text: $formVM.odometer)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 120)
                        Text("km").foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("加油量")
                        Spacer()
                        TextField("0", text: $formVM.fuelAmount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 120)
                        Text("L").foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("单价")
                        Spacer()
                        TextField("0", text: $formVM.pricePerLiter)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 120)
                        Text("¥/L").foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("总金额")
                        Spacer()
                        Text("¥\(Formatters.formatSimpleCurrency(formVM.totalCost))")
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                }
                
                Section("更多信息") {
                    Picker("是否加满", selection: $formVM.isFullTank) {
                        Text("是").tag(true)
                        Text("否").tag(false)
                    }
                    .pickerStyle(.segmented)
                    
                    HStack {
                        Text("燃油标号")
                        Spacer()
                        Picker("", selection: $formVM.fuelType) {
                            Text("92#").tag("92#")
                            Text("95#").tag("95#")
                            Text("98#").tag("98#")
                            Text("0#").tag("0#")
                        }
                        .pickerStyle(.menu)
                    }
                    
                    TextField("备注", text: $formVM.notes)
                }
                
                Section {
                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        HStack {
                            Spacer()
                            Label("删除记录", systemImage: "trash")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("编辑记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        guard let vehicle = dashboardVM.selectedVehicle else { return }
                        do {
                            try formVM.save(context: modelContext, vehicle: vehicle)
                            dismiss()
                        } catch {
                            saveError = error.localizedDescription
                            showSaveError = true
                        }
                    }
                    .disabled(!formVM.isValid)
                    .fontWeight(.semibold)
                }
            }
            .alert("确认删除", isPresented: $showDeleteConfirm) {
                Button("取消", role: .cancel) {}
                Button("删除", role: .destructive) {
                    formVM.editingRecord = record // 关联删除目标
                    do {
                        try formVM.delete(context: modelContext)
                        dismiss()
                    } catch {
                        saveError = error.localizedDescription
                        showSaveError = true
                    }
                }
            }
            .alert("保存失败", isPresented: $showSaveError) {
                Button("好的", role: .cancel) {}
            } message: {
                Text(saveError ?? "未知错误")
            }
            .onAppear {
                formVM.loadForEdit(record)
            }
        }
    }
}
