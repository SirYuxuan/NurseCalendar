import WidgetKit
import SwiftUI

struct ShiftWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> ShiftWidgetEntry {
        ShiftWidgetEntry(date: Date(), shifts: [.day, .night, .afterNight, .rest, .day, .night, .rest])
    }

    func getSnapshot(in context: Context, completion: @escaping (ShiftWidgetEntry) -> ()) {
        let currentDate = Date()
        var weekShifts: [ShiftType] = []
        
        // 获取本周的排班
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: currentDate) - 1  // 转换为0-6的范围
        let startDate = calendar.date(byAdding: .day, value: -weekday, to: currentDate)!  // 回到本周日
        
        // 从本周日开始，获取一周的数据
        for dayOffset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate)!
            let shift = ShiftDataManager.shared.getShift(for: date) ?? .rest
            weekShifts.append(shift)
        }
        
        let entry = ShiftWidgetEntry(date: currentDate, shifts: weekShifts)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ShiftWidgetEntry>) -> ()) {
        let currentDate = Date()
        var entries: [ShiftWidgetEntry] = []
        let calendar = Calendar.current
        
        // 获取本周的排班
        let weekday = calendar.component(.weekday, from: currentDate) - 1  // 转换为0-6的范围
        let startDate = calendar.date(byAdding: .day, value: -weekday, to: currentDate)!  // 回到本周日
        
        var weekShifts: [ShiftType] = []
        // 从本周日开始，获取一周的数据
        for dayOffset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate)!
            let shift = ShiftDataManager.shared.getShift(for: date) ?? .rest
            weekShifts.append(shift)
        }
        
        // 创建今天的条目
        let todayEntry = ShiftWidgetEntry(date: currentDate, shifts: weekShifts)
        entries.append(todayEntry)
        
        // 创建明天的条目（用于更新）
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: currentDate) {
            let tomorrowEntry = ShiftWidgetEntry(date: tomorrow, shifts: weekShifts)
            entries.append(tomorrowEntry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct ShiftWidgetEntry: TimelineEntry {
    let date: Date
    let shifts: [ShiftType]
    
    var currentShift: ShiftType {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date) - 1  // 转换为0-6的范围
        return shifts[weekday]
    }
}

struct ShiftWidgetEntryView : View {
    var entry: ShiftWidgetProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                singleDayView(entry: entry)
            case .systemMedium:
                weekView()
            default:
                singleDayView(entry: entry)
            }
        }
        .containerBackground(.background, for: .widget)
    }
    
    // 单日视图
    private func singleDayView(entry: ShiftWidgetEntry) -> some View {
        VStack {
            Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
            
            Text(entry.currentShift.name)
                .font(.title2)
                .foregroundColor(entry.currentShift.color)
                .padding(.vertical, 4)
            
            if entry.date.isToday {
                Text("今天")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
            }
        }
        .padding()
    }
    
    // 一周视图
    private func weekView() -> some View {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: entry.date) - 1  // 转换为0-6的范围
        let startDate = calendar.date(byAdding: .day, value: -weekday, to: entry.date)!  // 回到本周日
        
        return VStack(spacing: 8) {
            HStack {
                Text("本周排班")
                    .font(.headline)
                Spacer()
                if entry.date.isToday {
                    Text("今天")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(.quaternary))
                }
            }
            .padding(.horizontal)
            
            // 星期标题行
            HStack(spacing: 4) {
                ForEach(["日", "一", "二", "三", "四", "五", "六"], id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 8)
            
            // 日期网格
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                ForEach(0..<7) { index in
                    let currentDate = calendar.date(byAdding: .day, value: index, to: startDate)!
                    let shift = entry.shifts[index]
                    dayCell(date: currentDate, shift: shift)
                }
            }
            .padding(.horizontal, 8)
        }
        .padding(.vertical, 8)
    }
    
    // 日期单元格
    private func dayCell(date: Date, shift: ShiftType) -> some View {
        VStack(spacing: 2) {
            Text(String(dayNumber(from: date)))
                .font(.caption)
                .foregroundColor(date.isToday ? .white : .primary)
            Image(systemName: shiftIcon(for: shift))
                .font(.caption)
                .foregroundColor(date.isToday ? .white : shift.color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(date.isToday ? shift.color : shift.color.opacity(0.1))
        )
    }
    
    // 辅助函数
    private func dayNumber(from date: Date) -> Int {
        Calendar.current.component(.day, from: date)
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
}

struct ShiftWidget: Widget {
    let kind: String = "ShiftWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ShiftWidgetProvider()) { entry in
            ShiftWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("护士排班")
        .description("显示最近的排班信息")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

private extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
}

#Preview(as: .systemSmall) {
    ShiftWidget()
} timeline: {
    ShiftWidgetEntry(date: Date(), shifts: [.day, .night, .afterNight, .rest, .day, .night, .rest])
}

#Preview(as: .systemMedium) {
    ShiftWidget()
} timeline: {
    ShiftWidgetEntry(date: Date(), shifts: [.day, .night, .afterNight, .rest, .day, .night, .rest])
} 