import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct CSVImportView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var vehicles: [Vehicle]
    
    @State private var parsedRecords: [CSVService.ImportedRecord] = []
    @State private var importError: String?
    @State private var showFilePicker = false
    @State private var importComplete = false
    @State private var importedCount = 0
    @State private var skippedCount = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if importComplete {
                    importResultView
                } else if parsedRecords.isEmpty {
                    initialView
                } else {
                    previewView
                }
            }
            .navigationTitle("导入数据")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                if importComplete {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("完成") { dismiss() }
                    }
                }
            }
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: [UTType.commaSeparatedText, UTType.plainText],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result)
            }
            .onAppear {
                showFilePicker = true
            }
        }
    }
    
    private var initialView: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.and.arrow.down")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("选择 CSV 文件导入")
                .font(.headline)
            
            Text("支持「油耗记」导出的 CSV 格式\n或符合相同列结构的文件")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                showFilePicker = true
            } label: {
                Label("选择文件", systemImage: "folder.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .padding(.horizontal, 40)
            
            if let error = importError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
    }
    
    private var previewView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("预览导入数据")
                .font(.headline)
                .padding(.horizontal)
            
            Text("共解析 \(parsedRecords.count) 条记录，请确认后导入")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(Array(parsedRecords.enumerated()), id: \.offset) { index, record in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(record.vehicleName) · \(Formatters.csvDateFormatter.string(from: record.date))")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                Text("\(Formatters.formatOdometer(record.odometer))km · \(Formatters.formatFuelAmount(record.fuelAmount))L · ¥\(Formatters.formatSimpleCurrency(record.fuelAmount * record.pricePerLiter))")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: record.isFullTank ? "checkmark.circle.fill" : "circle")
                                .font(.caption)
                                .foregroundColor(record.isFullTank ? .green : .secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding(.horizontal)
            }
            
            Button {
                performImport()
            } label: {
                Label("确认导入 \(parsedRecords.count) 条记录", systemImage: "checkmark")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .padding(.horizontal)
            
            Button {
                parsedRecords = []
                importError = nil
                showFilePicker = true
            } label: {
                Text("重新选择文件")
                    .font(.subheadline)
            }
            .padding(.horizontal)
        }
    }
    
    private var importResultView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("导入完成")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 4) {
                Text("成功导入 \(importedCount) 条记录")
                    .foregroundColor(.green)
                if skippedCount > 0 {
                    Text("跳过 \(skippedCount) 条重复记录")
                        .foregroundColor(.secondary)
                }
            }
            .font(.subheadline)
        }
        .padding(.top, 40)
    }
    
    private func handleFileImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            guard url.startAccessingSecurityScopedResource() else {
                importError = "无法访问文件"
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }
            
            do {
                let content = try String(contentsOf: url, encoding: .utf8)
                parsedRecords = try CSVService.parseCSV(content)
                importError = nil
            } catch {
                importError = error.localizedDescription
                parsedRecords = []
            }
            
        case .failure(let error):
            importError = error.localizedDescription
            parsedRecords = []
        }
    }
    
    private func performImport() {
        var imported = 0
        var skipped = 0
        
        for parsed in parsedRecords {
            let targetVehicle: Vehicle
            if let existing = vehicles.first(where: { $0.name == parsed.vehicleName }) {
                targetVehicle = existing
            } else {
                // 自动创建未知车辆
                let newVehicle = Vehicle(name: parsed.vehicleName, type: .car, fuelType: parsed.fuelType)
                modelContext.insert(newVehicle)
                targetVehicle = newVehicle
            }
            
            let record = FuelRecord(
                date: parsed.date,
                odometer: parsed.odometer,
                fuelAmount: parsed.fuelAmount,
                pricePerLiter: parsed.pricePerLiter,
                isFullTank: parsed.isFullTank,
                fuelType: parsed.fuelType,
                notes: parsed.notes
            )
            record.vehicle = targetVehicle
            modelContext.insert(record)
            imported += 1
        }
        
        do {
            try modelContext.save()
            importedCount = imported
            skippedCount = skipped
            importComplete = true
            parsedRecords = []
        } catch {
            importError = error.localizedDescription
            importedCount = 0
            importComplete = false
        }
    }
}
