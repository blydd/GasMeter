import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct CSVExportView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var csvContent: String = ""
    @State private var exportURL: URL?
    @State private var recordCount = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if recordCount == 0 {
                    ContentUnavailableView(
                        "暂无数据可导出",
                        systemImage: "tray",
                        description: Text("请先添加车辆和加油记录")
                    )
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text("共 \(recordCount) 条记录")
                            .font(.title3)
                            .fontWeight(.medium)
                        
                        Text("导出格式：CSV (UTF-8)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // CSV 内容预览
                        ScrollView {
                            Text(csvContent)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxHeight: 300)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal)
                        
                        HStack(spacing: 16) {
                            // 分享按钮
                            if let url = exportURL {
                                ShareLink(item: url) {
                                    Label("分享导出", systemImage: "square.and.arrow.up")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.orange)
                            }
                            
                            // 复制按钮
                            Button {
                                UIPasteboard.general.string = csvContent
                            } label: {
                                Label("复制", systemImage: "doc.on.doc")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("导出数据")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
            }
            .onAppear { prepareExport() }
        }
    }
    
    private func prepareExport() {
        let descriptor = FetchDescriptor<FuelRecord>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        let allRecords = (try? modelContext.fetch(descriptor)) ?? []
        recordCount = allRecords.count
        csvContent = CSVService.exportCSV(records: allRecords)
        exportURL = try? CSVService.exportToFile(records: allRecords)
    }
}
