import SwiftUI
import Charts

struct MonthlyEfficiencyChart: View {
    let data: [(month: String, value: Double)]
    
    /// 按完整 "yyyy-MM" 标识符排序后的数据
    private var sortedData: [(month: String, value: Double)] {
        data.sorted { $0.month < $1.month }
    }
    
    var body: some View {
        Chart {
            ForEach(sortedData, id: \.month) { item in
                LineMark(
                    x: .value("月份", item.month),
                    y: .value("油耗", item.value)
                )
                .foregroundStyle(Color.orange.gradient)
                .interpolationMethod(.catmullRom)
                
                PointMark(
                    x: .value("月份", item.month),
                    y: .value("油耗", item.value)
                )
                .foregroundStyle(Color.orange)
            }
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel(format: ShortMonthFormat())
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let v = value.as(Double.self) {
                        Text(String(format: "%.1f", v))
                    }
                }
            }
        }
    }
}

struct MonthlyCostChart: View {
    let data: [(month: String, value: Double)]
    
    /// 按完整 "yyyy-MM" 标识符排序后的数据
    private var sortedData: [(month: String, value: Double)] {
        data.sorted { $0.month < $1.month }
    }
    
    var body: some View {
        Chart {
            ForEach(sortedData, id: \.month) { item in
                BarMark(
                    x: .value("月份", item.month),
                    y: .value("油费", item.value)
                )
                .foregroundStyle(Color.orange.gradient.opacity(0.8))
                .cornerRadius(4)
            }
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel(format: ShortMonthFormat())
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let v = value.as(Double.self) {
                        Text("¥\(Int(v))")
                    }
                }
            }
        }
    }
}

/// 月份格式化：将 "2025-01" 显示为 "1月"
struct ShortMonthFormat: FormatStyle {
    func format(_ value: String) -> String {
        let parts = value.components(separatedBy: "-")
        guard parts.count == 2, let monthInt = Int(parts[1]) else { return value }
        return "\(monthInt)月"
    }
}

#Preview {
    VStack {
        MonthlyEfficiencyChart(data: [
            ("2025-01", 6.8), ("2025-02", 7.1), ("2025-03", 6.9),
            ("2025-04", 6.5), ("2025-05", 6.7), ("2025-06", 6.6),
        ])
        MonthlyCostChart(data: [
            ("2025-01", 1200), ("2025-02", 980), ("2025-03", 1350),
            ("2025-04", 1100), ("2025-05", 890), ("2025-06", 1050),
        ])
    }
    .padding()
}
