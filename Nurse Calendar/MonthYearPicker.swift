import SwiftUI

struct MonthYearPicker: View {
    @Binding var selectedDate: Date
    @Environment(\.calendar) private var calendar
    
    private let years = Array(2020...2030)
    private let months = Array(1...12)
    
    var body: some View {
        HStack {
            // 年份选择器
            Picker("年", selection: Binding(
                get: {
                    calendar.component(.year, from: selectedDate)
                },
                set: { newYear in
                    if let date = calendar.date(byAdding: .year,
                                             value: newYear - calendar.component(.year, from: selectedDate),
                                             to: selectedDate) {
                        selectedDate = date
                    }
                }
            )) {
                ForEach(years, id: \.self) { year in
                    Text(String(format: "%d年", year))
                        .tag(year)
                }
            }
            .pickerStyle(.wheel)

            // 月份选择器
            Picker("月", selection: Binding(
                get: {
                    calendar.component(.month, from: selectedDate)
                },
                set: { newMonth in
                    if let date = calendar.date(byAdding: .month,
                                             value: newMonth - calendar.component(.month, from: selectedDate),
                                             to: selectedDate) {
                        selectedDate = date
                    }
                }
            )) {
                ForEach(months, id: \.self) { month in
                    Text(String(format: "%d月", month))
                        .tag(month)
                }
            }
            .pickerStyle(.wheel)
        }
        .padding()
    }
} 