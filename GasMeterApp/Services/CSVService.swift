import Foundation
import UniformTypeIdentifiers

/// CSV 导入导出服务
struct CSVService {
    
    // MARK: - 导出
    
    /// BOM 字节标记（确保 Excel 正确识别 UTF-8 中文）
    private static let bom = "\u{FEFF}"
    
    static func exportCSV(records: [FuelRecord]) -> String {
        var csv = bom
        csv += "日期,车辆,里程表(km),加油量(L),单价(元/L),总金额(元),是否加满,燃油标号,备注\n"
        for r in records.sorted(by: { $0.date > $1.date }) {
            let vehicleName = r.vehicle?.name ?? "未知"
            let dateStr = Formatters.csvDateFormatter.string(from: r.date)
            let fullTank = r.isFullTank ? "是" : "否"
            let notes = r.notes.replacingOccurrences(of: ",", with: "，")
            csv += "\(dateStr),\(vehicleName),\(r.odometer),\(r.fuelAmount),\(r.pricePerLiter),\(String(format: "%.2f", r.totalCost)),\(fullTank),\(r.fuelType),\(notes)\n"
        }
        return csv
    }
    
    /// 将 CSV 数据写入临时文件并返回 URL
    static func exportToFile(records: [FuelRecord]) throws -> URL {
        let csv = exportCSV(records: records)
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "油耗记_导出_\(Formatters.csvDateFormatter.string(from: Date())).csv"
        let fileURL = tempDir.appendingPathComponent(fileName)
        try csv.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }
    
    // MARK: - 导入
    
    struct ImportedRecord {
        let date: Date
        let vehicleName: String
        let odometer: Double
        let fuelAmount: Double
        let pricePerLiter: Double
        let isFullTank: Bool
        let fuelType: String
        let notes: String
    }
    
    enum CSVError: LocalizedError {
        case invalidFormat
        case missingRequiredColumns
        case parseError(String)
        
        var errorDescription: String? {
            switch self {
            case .invalidFormat: return "CSV 文件格式无效"
            case .missingRequiredColumns: return "缺少必需列（日期、车辆、里程表、加油量、单价）"
            case .parseError(let msg): return "解析错误: \(msg)"
            }
        }
    }
    
    /// 解析 CSV 内容为 ImportedRecord 列表
    static func parseCSV(_ content: String) throws -> [ImportedRecord] {
        var lines = content.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        // 移除 BOM 头
        if let first = lines.first, first.hasPrefix(bom) {
            lines[0] = String(first.dropFirst(bom.count))
        }
        
        guard lines.count >= 2 else { throw CSVError.invalidFormat }
        
        let headers = parseCSVLine(lines[0])
        guard let dateIdx = headers.firstIndex(where: { $0.contains("日期") }),
              let vehicleIdx = headers.firstIndex(where: { $0.contains("车辆") }),
              let odoIdx = headers.firstIndex(where: { $0.contains("里程") }),
              let amountIdx = headers.firstIndex(where: { $0.contains("加油量") }),
              let priceIdx = headers.firstIndex(where: { $0.contains("单价") }) else {
            throw CSVError.missingRequiredColumns
        }
        
        let fullTankIdx = headers.firstIndex(where: { $0.contains("加满") })
        let fuelTypeIdx = headers.firstIndex(where: { $0.contains("标号") })
        let notesIdx = headers.firstIndex(where: { $0.contains("备注") })
        
        var records: [ImportedRecord] = []
        for i in 1..<lines.count {
            let fields = parseCSVLine(lines[i])
            let maxRequiredIdx = [dateIdx, vehicleIdx, odoIdx, amountIdx, priceIdx,
                                  fullTankIdx, fuelTypeIdx, notesIdx].compactMap { $0 }.max() ?? 0
            guard fields.count > maxRequiredIdx else { continue }
            
            guard let date = Formatters.csvDateFormatter.date(from: fields[dateIdx]),
                  let odo = Double(fields[odoIdx]),
                  let amount = Double(fields[amountIdx]),
                  let price = Double(fields[priceIdx]) else {
                throw CSVError.parseError("第 \(i+1) 行数据格式错误")
            }
            
            let fullTank: Bool = {
                if let idx = fullTankIdx, idx < fields.count {
                    return fields[idx] == "是" || fields[idx].lowercased() == "true"
                }
                return true
            }()
            
            let fuelType = (fuelTypeIdx != nil && fuelTypeIdx! < fields.count) ? fields[fuelTypeIdx!] : "92#"
            let notes = (notesIdx != nil && notesIdx! < fields.count) ? fields[notesIdx!] : ""
            
            records.append(ImportedRecord(
                date: date,
                vehicleName: fields[vehicleIdx],
                odometer: odo,
                fuelAmount: amount,
                pricePerLiter: price,
                isFullTank: fullTank,
                fuelType: fuelType,
                notes: notes
            ))
        }
        return records
    }
    
    /// 解析单行 CSV（处理引号内逗号）
    private static func parseCSVLine(_ line: String) -> [String] {
        var result: [String] = []
        var current = ""
        var inQuotes = false
        for char in line {
            switch char {
            case "\"":
                inQuotes.toggle()
            case ",":
                if inQuotes {
                    current.append(char)
                } else {
                    result.append(current.trimmingCharacters(in: .whitespaces))
                    current = ""
                }
            default:
                current.append(char)
            }
        }
        result.append(current.trimmingCharacters(in: .whitespaces))
        return result
    }
    
    static var csvUTType: UTType {
        UTType.commaSeparatedText
    }
}
