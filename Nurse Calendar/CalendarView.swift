import SwiftUI

struct CalendarView: View {
    let date: Date  // 当前显示的月份
    @Binding var selectedDate: Date
    @Environment(\.calendar) var calendar
    private let daysOfWeek = ["日", "一", "二", "三", "四", "五", "六"]
    
    // 判断是否是当前显示的月份
    private func isInCurrentMonth(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: self.date, toGranularity: .month)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // 星期显示
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.gray)
                }
            }
            
            // 调整网格间距
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(Array(getDays().enumerated()), id: \.offset) { index, date in
                    if let date = date {
                        DayView(date: date, 
                               selectedDate: $selectedDate,
                               isInDisplayedMonth: isInCurrentMonth(date))
                    } else {
                        Text("")
                            .frame(height: 58)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func getDays() -> [Date?] {
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let range = calendar.range(of: .day, in: .month, for: start)!
        
        let firstWeekday = calendar.component(.weekday, from: start)
        let leadingSpaces = firstWeekday - 1
        
        var days: [Date?] = Array(repeating: nil, count: leadingSpaces)
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: start) {
                days.append(date)
            }
        }
        
        let remainingSpaces = 42 - days.count
        days += Array(repeating: nil, count: remainingSpaces)
        
        return days
    }
} 