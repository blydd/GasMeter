import SwiftUI

struct RecordRowView: View {
    let record: FuelRecord
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(Formatters.shortDateFormatter.string(from: record.date))
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 8) {
                    Text("\(Formatters.formatOdometer(record.odometer)) km")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Formatters.formatFuelAmount(record.fuelAmount)) L")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("¥\(Formatters.formatSimpleCurrency(record.totalCost))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                
                HStack(spacing: 4) {
                    if record.isFullTank {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.green)
                        Text("加满")
                            .font(.caption2)
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "circle")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("未加满")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
