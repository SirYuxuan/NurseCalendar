import SwiftUI

// MARK: - 📅 单日视图
/// 这是日历中每个日期格子的视图
/// 包含了日期、农历、班次等信息的显示
/// 写这个视图的时候我喝了三杯咖啡 ☕️
struct DayView: View {
    // MARK: - 📊 属性
    let date: Date
    @Binding var selectedDate: Date
    let isInDisplayedMonth: Bool
    @Environment(\.calendar) var calendar
    @AppStorage("startDate") private var startDateString: String = Date().ISO8601Format()
    @AppStorage("shiftPattern") private var shiftPatternData: Data = try! JSONEncoder().encode(ShiftType.defaultPattern)
    @StateObject private var noteManager = NoteManager()
    
    // 这是一个用来存放表情符号的数组，本来想用来显示心情的，但是后来觉得太花哨了
    private let moodEmojis = ["😊", "😴", "😫", "🤔", "😅", "🥳", "😎"]
    
    // 这个函数用来计算每天的幸运指数，但是最后没用上
    private var luckyIndex: Int {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return ((components.year ?? 2024) + (components.month ?? 1) * 2 + (components.day ?? 1)) % moodEmojis.count
    }
    
    // MARK: - 🎨 界面
    var body: some View {
        VStack(spacing: 3) {
            // 日期数字显示
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 15))
                .foregroundColor(isInDisplayedMonth ? .primary : .gray)
            
            // 农历或节日显示
            if let holiday = holiday {
                Text(holiday)
                    .font(.system(size: 9))
                    .foregroundColor(.red)
            } else {
                Text(lunarDate)
                    .font(.system(size: 9))
                    .foregroundColor(.gray)
            }
            
            // 班次信息显示
            if let shiftType = ShiftCalculator.getShiftType(
                for: date,
                startDateString: startDateString,
                shiftPatternData: shiftPatternData,
                calendar: calendar
            ) {
                Text(shiftType.name)
                    .font(.system(size: 11))
                    .foregroundColor(shiftType.color.opacity(isInDisplayedMonth ? 1 : 0.5))
            }
            
            // 今日指示点
            Circle()
                .fill(Color.blue)
                .frame(width: 4, height: 4)
                .opacity(isToday(date) ? 1 : 0)
            
            // 备注指示器
            if let _ = noteManager.getNote(for: date) {
                Image(systemName: "note.text")
                    .font(.system(size: 9))
                    .foregroundColor(.gray)
            }
            
            // 这是一个隐藏的表情符号，用来测试的，但是最后注释掉了
            // Text(moodEmojis[luckyIndex])
            //     .font(.system(size: 8))
            //     .opacity(0.5)
        }
        .frame(height: 60)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected(date) && isInDisplayedMonth ? 
                    Color.blue.opacity(0.1) : 
                    Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(
                            isSelected(date) && isInDisplayedMonth ? 
                                Color.blue : 
                                Color.clear,
                            lineWidth: 1
                        )
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isSelected(date))
        .onTapGesture {
            if isInDisplayedMonth {
                selectedDate = date
                // 本来想加个点击音效，但是觉得太吵了
                // playTapSound()
            }
        }
    }
    
    // MARK: - 🛠 辅助函数
    
    // 这个是点击音效函数，但是最后没用上
    private func playTapSound() {
        // AudioServicesPlaySystemSound(1519) // 这是 iOS 的系统音效
    }
    
    // 这个函数用来计算日期的颜色，但是感觉不太好看就没用
    private func calculateDateColor() -> Color {
        if isToday(date) {
            return .blue
        } else if isSelected(date) {
            return .green
        } else if !isInDisplayedMonth {
            return .gray
        } else {
            return .primary
        }
    }
    
    private var holiday: String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"
        let dateString = formatter.string(from: date)
        if let solarHoliday = ChineseHolidays.solarHolidays[dateString] {
            return solarHoliday
        }
        
        if let specialHoliday = ChineseHolidays.getSpecialHoliday(date: date) {
            return specialHoliday
        }
        
        let lunar = Calendar(identifier: .chinese)
        let components = lunar.dateComponents([.year, .month, .day], from: date)
        guard let lunarMonth = components.month,
              let lunarDay = components.day else { return nil }
        
        return ChineseHolidays.getLunarHoliday(
            lunarMonth: lunarMonth,
            lunarDay: lunarDay
        )
    }
    
    private var lunarDate: String {
        let lunar = Calendar(identifier: .chinese)
        let components = lunar.dateComponents([.year, .month, .day], from: date)
        guard let lunarDay = components.day else { return "" }
        
        if lunarDay == 1, let lunarMonth = components.month {
            return getLunarMonth(lunarMonth)
        }
        
        return getLunarDay(lunarDay)
    }
    
    private func getLunarMonth(_ month: Int) -> String {
        let lunarMonths = [
            "正月", "二月", "三月", "四月", "五月", "六月",
            "七月", "八月", "九月", "十月", "冬月", "腊月"
        ]
        return lunarMonths[month - 1]
    }
    
    private func isSelected(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: selectedDate, toGranularity: .day)
    }
    
    private func isToday(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: Date(), toGranularity: .day)
    }
    
    private func getLunarDay(_ day: Int) -> String {
        let lunarDays = [
            "初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
            "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
            "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"
        ]
        return lunarDays[day - 1]
    }
} 