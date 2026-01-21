import SwiftUI

struct CalendarView: View {
    let date: Date  // 当前显示的月份
    @Binding var selectedDate: Date
    @AppStorage("weekStartsOnMonday") private var weekStartsOnMonday: Bool = false

    private var calendar: Calendar {
        var cal = Calendar.current
        cal.locale = Locale(identifier: "zh_CN")
        // 设置每周起始日：1 = 周日，2 = 周一
        cal.firstWeekday = weekStartsOnMonday ? 2 : 1
        return cal
    }

    private var daysOfWeek: [String] {
        if weekStartsOnMonday {
            return ["一", "二", "三", "四", "五", "六", "日"]
        } else {
            return ["日", "一", "二", "三", "四", "五", "六"]
        }
    }

    // 判断是否是当前显示的月份
    private func isInCurrentMonth(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: self.date, toGranularity: .month)
    }

    var body: some View {
        VStack(spacing: 20) {
            // 星期显示
            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 15, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                }
            }
            .cornerRadius(8)

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

            Spacer(minLength: 0)
        }
        .padding(.horizontal)
        .frame(minHeight: 480)
    }

    private func getDays() -> [Date?] {
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let range = calendar.range(of: .day, in: .month, for: start)!

        let firstWeekday = calendar.component(.weekday, from: start)
        // 计算前导空格：根据每周起始日调整
        let leadingSpaces: Int
        if weekStartsOnMonday {
            // 周一开始：周一=0, 周二=1, ..., 周日=6
            leadingSpaces = (firstWeekday + 5) % 7
        } else {
            // 周日开始：周日=0, 周一=1, ..., 周六=6
            leadingSpaces = firstWeekday - 1
        }

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