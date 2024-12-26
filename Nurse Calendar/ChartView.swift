import SwiftUI
import Charts

struct ShiftChartView: View {
    let shiftCounts: [(shift: ShiftType, count: Int)]
    
    var body: some View {
        Chart {
            ForEach(shiftCounts, id: \.shift) { item in
                BarMark(
                    x: .value("班次", item.shift.name),
                    y: .value("数量", item.count)
                )
                .foregroundStyle(item.shift.color)
            }
        }
        .frame(height: 200)
        .padding()
    }
} 