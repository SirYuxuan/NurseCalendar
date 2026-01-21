import WidgetKit
import SwiftUI

struct ShiftWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> ShiftWidgetEntry {
        let calendar = Calendar.current
        let currentDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -30, to: currentDate)!

        return ShiftWidgetEntry(
            date: currentDate,
            shifts: generateShifts(from: startDate, count: 72),
            weekStartsOnMonday: false
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ShiftWidgetEntry) -> ()) {
        let calendar = Calendar.current
        let currentDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -30, to: currentDate)!

        let entry = ShiftWidgetEntry(
            date: currentDate,
            shifts: generateShifts(from: startDate, count: 72),
            weekStartsOnMonday: ShiftDataManager.shared.getWeekStartsOnMonday()
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ShiftWidgetEntry>) -> ()) {
        let currentDate = Date()
        let calendar = Calendar.current
        let weekStartsOnMonday = ShiftDataManager.shared.getWeekStartsOnMonday()

        // 从30天前开始生成，确保覆盖所有可能显示的日期
        let startDate = calendar.date(byAdding: .day, value: -30, to: currentDate)!
        let entry = ShiftWidgetEntry(
            date: currentDate,
            shifts: generateShifts(from: startDate, count: 72), // 30天前 + 42天后
            weekStartsOnMonday: weekStartsOnMonday
        )

        // 每天午夜更新
        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: currentDate)!)
        let timeline = Timeline(entries: [entry], policy: .after(tomorrow))
        completion(timeline)
    }

    private func generateShifts(from startDate: Date, count: Int) -> [(date: Date, shift: ShiftType)] {
        let calendar = Calendar.current
        var shifts: [(date: Date, shift: ShiftType)] = []
        let defaultPattern: [ShiftType] = [.day, .night, .afterNight, .rest]

        for i in 0..<count {
            if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                let shift = ShiftDataManager.shared.getShift(for: date) ?? defaultPattern[i % defaultPattern.count]
                shifts.append((date, shift))
            }
        }

        return shifts
    }
}

struct ShiftWidgetEntry: TimelineEntry {
    let date: Date
    let shifts: [(date: Date, shift: ShiftType)]
    let weekStartsOnMonday: Bool

    var todayShift: ShiftType? {
        shifts.first?.shift
    }
}

struct ShiftWidgetEntryView: View {
    var entry: ShiftWidgetEntry
    @Environment(\.widgetFamily) var family

    private var daysOfWeek: [String] {
        if entry.weekStartsOnMonday {
            return ["一", "二", "三", "四", "五", "六", "日"]
        } else {
            return ["日", "一", "二", "三", "四", "五", "六"]
        }
    }

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                smallView
            case .systemMedium:
                mediumView
            case .systemLarge:
                largeView
            default:
                smallView
            }
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }

    // MARK: - 小尺寸：显示一周（横向排列）
    private var smallView: some View {
        let weekDates = getAlignedWeekDates(from: entry.date)
        let todayShift = entry.shifts.first(where: { Calendar.current.isDateInToday($0.date) })

        return VStack(spacing: 0) {
            // 今日信息
            if let todayShift = todayShift {
                VStack(spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: shiftIcon(for: todayShift.shift))
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(todayShift.shift.color)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("今天")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                            Text(todayShift.shift.name)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primary)
                        }

                        Spacer()
                    }
                }
                .padding(.bottom, 12)
            }

            // 星期头部
            HStack(spacing: 2) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 4)

            // 一周排班（横向）
            HStack(spacing: 2) {
                ForEach(Array(weekDates.enumerated()), id: \.offset) { index, date in
                    if let shiftItem = entry.shifts.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
                        dayCellSmallHorizontal(
                            date: shiftItem.date,
                            shift: shiftItem.shift,
                            isToday: Calendar.current.isDateInToday(date)
                        )
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(12)
    }

    // MARK: - 日期单元格（小尺寸 - 横向）
    private func dayCellSmallHorizontal(date: Date, shift: ShiftType, isToday: Bool) -> some View {
        let day = Calendar.current.component(.day, from: date)

        return VStack(spacing: 2) {
            Text("\(day)")
                .font(.system(size: 9, weight: isToday ? .bold : .medium))
                .foregroundColor(isToday ? .white : .primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            RoundedRectangle(cornerRadius: 2)
                .fill(shift.color)
                .frame(height: 4)
                .padding(.horizontal, 1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .padding(.horizontal, 1)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isToday ? shift.color : shift.color.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isToday ? shift.color : Color.clear, lineWidth: isToday ? 2 : 0)
        )
    }

    private func smallPlaceholderCell() -> some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color.clear)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
    }

    // MARK: - 中尺寸：显示三周（紧凑版）
    private var mediumView: some View {
        let alignedDates = getAlignedDates(from: entry.date, weeks: 3)

        return VStack(spacing: 5) {
            // 星期头部
            HStack(spacing: 2) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // 三周排班
            ForEach(0..<3, id: \.self) { weekIndex in
                HStack(spacing: 2) {
                    ForEach(0..<7, id: \.self) { dayIndex in
                        let dateIndex = weekIndex * 7 + dayIndex
                        if dateIndex < alignedDates.count {
                            let date = alignedDates[dateIndex]
                            if let shiftItem = entry.shifts.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
                                dayCellMedium(date: shiftItem.date, shift: shiftItem.shift)
                            } else {
                                Color.clear.frame(maxWidth: .infinity)
                            }
                        } else {
                            Color.clear.frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
    }

    // 调试用日期格式化
    private func formatDebugDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }

    // MARK: - 大尺寸：显示5周，今天在第一行
    private var largeView: some View {
        let weekDates = getFiveWeeksWithTodayFirst(from: entry.date)

        return VStack(spacing: 0) {
            // 标题栏
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                    Text("排班日历")
                        .font(.system(size: 15, weight: .semibold))
                }

                Spacer()

                Text(formatMonthYear(entry.date))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.1))
                    )
            }
            .padding(.bottom, 8)

            Spacer()

            // 星期头部
            HStack(spacing: 2) {
                ForEach(Array(daysOfWeek.enumerated()), id: \.offset) { index, day in
                    Text(day)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(isWeekend(index) ? .red.opacity(0.8) : .secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 4)

            // 5周排班（今天在第一行）
            VStack(spacing: 5) {
                ForEach(0..<5, id: \.self) { weekIndex in
                    HStack(spacing: 2) {
                        ForEach(0..<7, id: \.self) { dayIndex in
                            let dateIndex = weekIndex * 7 + dayIndex
                            if dateIndex < weekDates.count {
                                let date = weekDates[dateIndex]
                                if let shiftItem = entry.shifts.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
                                    dayCellLarge(
                                        date: shiftItem.date,
                                        shift: shiftItem.shift,
                                        isWeekendDay: isWeekend(dayIndex)
                                    )
                                } else {
                                    placeholderCell(isWeekendDay: isWeekend(dayIndex))
                                }
                            } else {
                                placeholderCell(isWeekendDay: isWeekend(dayIndex))
                            }
                        }
                    }
                }
            }

            Spacer()

            // 底部图例
            HStack(spacing: 12) {
                ForEach([ShiftType.day, .night, .afterNight, .rest], id: \.self) { shift in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(shift.color)
                            .frame(width: 6, height: 6)
                        Text(shift.name)
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.top, 4)
        }
        .padding(12)
    }

    // MARK: - 占位单元格
    private func placeholderCell(isWeekendDay: Bool) -> some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
    }

    // MARK: - 日期单元格（中尺寸）
    private func dayCellMedium(date: Date, shift: ShiftType) -> some View {
        let isToday = Calendar.current.isDateInToday(date)
        let day = Calendar.current.component(.day, from: date)

        return VStack(spacing: 1) {
            Text("\(day)")
                .font(.system(size: 10, weight: isToday ? .bold : .regular))
                .foregroundColor(isToday ? .white : .primary)

            Text(shift.shortName)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(isToday ? .white : shift.color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(isToday ? shift.color : shift.color.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(isToday ? shift.color : Color.clear, lineWidth: 1)
        )
    }

    // MARK: - 日期单元格（大尺寸）
    private func dayCellLarge(date: Date, shift: ShiftType, isWeekendDay: Bool) -> some View {
        let isToday = Calendar.current.isDateInToday(date)
        let day = Calendar.current.component(.day, from: date)

        return VStack(spacing: 1) {
            Text("\(day)")
                .font(.system(size: 12, weight: isToday ? .bold : .regular))
                .foregroundColor(isToday ? .white : (isWeekendDay ? .red.opacity(0.8) : .primary))

            Text(shift.shortName)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(isToday ? .white : shift.color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(isToday ? shift.color : shift.color.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(isToday ? shift.color : Color.clear, lineWidth: 1)
        )
    }

    // MARK: - 辅助方法
    private func isWeekend(_ dayIndex: Int) -> Bool {
        if entry.weekStartsOnMonday {
            return dayIndex >= 5 // 周六(5)、周日(6)
        } else {
            return dayIndex == 0 || dayIndex == 6 // 周日(0)、周六(6)
        }
    }

    private func formatShortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }

    private func formatWeekday(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }

    private func formatMonthYear(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月"
        return formatter.string(from: date)
    }

    private func shiftIcon(for shift: ShiftType) -> String {
        switch shift {
        case .day: return "sun.max.fill"
        case .night: return "moon.stars.fill"
        case .afterNight: return "sunrise.fill"
        case .rest: return "bed.double.fill"
        case .custom: return "calendar"
        }
    }

    // MARK: - 日期对齐方法

    /// 获取包含今天的当前周的日期（对齐到周起始日）
    private func getAlignedWeekDates(from date: Date) -> [Date] {
        var cal = Calendar.current
        // 根据设置调整一周的起始日
        cal.firstWeekday = entry.weekStartsOnMonday ? 2 : 1  // 2 = 周一, 1 = 周日

        // 获取当前日期所在周的开始日期（使用已调整的日历）
        guard let weekStart = cal.dateInterval(of: .weekOfYear, for: date)?.start else {
            return []
        }

        // 生成一周的日期（使用相同的日历以保持一致）
        var dates: [Date] = []
        for i in 0..<7 {
            if let nextDate = cal.date(byAdding: .day, value: i, to: weekStart) {
                dates.append(nextDate)
            }
        }
        return dates
    }

    /// 获取对齐到周起始日的多周日期
    private func getAlignedDates(from date: Date, weeks: Int) -> [Date] {
        var cal = Calendar.current
        // 根据设置调整一周的起始日
        cal.firstWeekday = entry.weekStartsOnMonday ? 2 : 1

        // 获取当前日期所在周的开始日期（使用已调整的日历）
        guard let weekStart = cal.dateInterval(of: .weekOfYear, for: date)?.start else {
            return []
        }

        // 生成指定周数的日期（使用调整后的日历）
        var dates: [Date] = []
        for i in 0..<(weeks * 7) {
            if let nextDate = cal.date(byAdding: .day, value: i, to: weekStart) {
                dates.append(nextDate)
            }
        }
        return dates
    }

    /// 获取5周的日期，今天在第一行
    private func getFiveWeeksWithTodayFirst(from date: Date) -> [Date] {
        var cal = Calendar.current
        // 根据设置调整一周的起始日
        cal.firstWeekday = entry.weekStartsOnMonday ? 2 : 1

        // 获取今天所在周的开始日期
        guard let weekStart = cal.dateInterval(of: .weekOfYear, for: date)?.start else {
            return []
        }

        // 从今天所在周的开始，生成5周的日期
        var dates: [Date] = []
        for i in 0..<35 { // 5周 * 7天
            if let nextDate = cal.date(byAdding: .day, value: i, to: weekStart) {
                dates.append(nextDate)
            }
        }
        return dates
    }

    /// 获取完整月份的日期（包含上月末尾和下月开头以填充完整周）
    private func getMonthDates(for date: Date) -> [(date: Date?, isCurrentMonth: Bool)] {
        let calendar = Calendar.current
        var cal = calendar
        // 根据设置调整一周的起始日
        cal.firstWeekday = entry.weekStartsOnMonday ? 2 : 1

        // 获取当月的第一天
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let firstDayOfMonth = calendar.date(from: components) else {
            return []
        }

        // 获取当月第一天所在周的开始日期
        guard let monthWeekStart = cal.dateInterval(of: .weekOfYear, for: firstDayOfMonth)?.start else {
            return []
        }

        // 获取当月的天数
        guard let range = calendar.range(of: .day, in: .month, for: date) else {
            return []
        }
        let daysInMonth = range.count

        // 计算需要显示几周（通常是 4-6 周）
        let firstWeekday = cal.component(.weekday, from: firstDayOfMonth)
        let adjustedFirstWeekday = entry.weekStartsOnMonday ? (firstWeekday == 1 ? 7 : firstWeekday - 1) : firstWeekday
        let totalDaysNeeded = adjustedFirstWeekday + daysInMonth - 1
        let weeksNeeded = (totalDaysNeeded + 6) / 7  // 向上取整

        // 生成所有日期（使用调整后的日历和 monthWeekStart）
        var dates: [(date: Date?, isCurrentMonth: Bool)] = []
        for i in 0..<(weeksNeeded * 7) {
            if let currentDate = cal.date(byAdding: .day, value: i, to: monthWeekStart) {
                let isInCurrentMonth = cal.isDate(currentDate, equalTo: date, toGranularity: .month)
                dates.append((currentDate, isInCurrentMonth))
            } else {
                dates.append((nil, false))
            }
        }

        return dates
    }
}

// MARK: - ShiftType 扩展
extension ShiftType {
    var shortName: String {
        switch self {
        case .day: return "白"
        case .night: return "夜"
        case .afterNight: return "下"
        case .rest: return "休"
        case .custom(let name): return String(name.prefix(1))
        }
    }
}

// MARK: - Widget 配置
struct ShiftWidget: Widget {
    let kind: String = "ShiftWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ShiftWidgetProvider()) { entry in
            ShiftWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("排班日历")
        .description("小尺寸显示一周，中尺寸显示三周，大尺寸显示完整月份")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - 预览
#Preview(as: .systemSmall) {
    ShiftWidget()
} timeline: {
    ShiftWidgetEntry(
        date: Date(),
        shifts: generatePreviewShifts(),
        weekStartsOnMonday: false
    )
}

#Preview(as: .systemMedium) {
    ShiftWidget()
} timeline: {
    ShiftWidgetEntry(
        date: Date(),
        shifts: generatePreviewShifts(),
        weekStartsOnMonday: false
    )
}

#Preview(as: .systemLarge) {
    ShiftWidget()
} timeline: {
    ShiftWidgetEntry(
        date: Date(),
        shifts: generatePreviewShifts(),
        weekStartsOnMonday: false
    )
}

// 预览用的数据生成
private func generatePreviewShifts() -> [(date: Date, shift: ShiftType)] {
    let calendar = Calendar.current
    var shifts: [(date: Date, shift: ShiftType)] = []
    let pattern: [ShiftType] = [.day, .night, .afterNight, .rest]
    // 生成42天的数据（足够显示一个完整月份）
    for i in 0..<42 {
        if let date = calendar.date(byAdding: .day, value: i, to: Date()) {
            shifts.append((date, pattern[i % pattern.count]))
        }
    }
    return shifts
}
