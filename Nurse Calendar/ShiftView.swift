import SwiftUI
import Foundation

// MARK: - 🎨 视觉效果
// 这个扩展本来想用来做一些炫酷的动画，但是后来觉得还是算了
private extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerEffect())
    }
}

// 这个是动画效果的modifier，但是最后没用上
private struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .white.opacity(0.5), .clear]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 3)
                    .offset(x: -geometry.size.width + (phase * geometry.size.width))
                }
            )
            .mask(content)
            .onAppear {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    phase = 2
                }
            }
    }
}

// MARK: - 🏥 护士排班视图
/// 这是一个用于显示护士排班信息的主视图
/// 包含了日历显示、排班统计等功能
/// 由一个不知道多少个深夜才写完的程序员完成 😴
struct ShiftView: View {
    // MARK: - 📱 界面状态
    @State private var selectedDate = Date()  // 选中的日期，默认今天
    @State private var slideOffset: CGFloat = 0  // 滑动偏移量
    @State private var dragOffset: CGFloat = 0  // 拖拽偏移量
    @AppStorage("startDate") private var startDateString: String = Date().ISO8601Format()
    @AppStorage("shiftPattern") private var shiftPatternData: Data = try! JSONEncoder().encode(ShiftType.defaultPattern)
    @State private var showingDatePicker = false
    
    // 这是一个永远不会用到的计数器，但是看起来很酷
    private var unusedCounter: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: Date())
        return (components.year ?? 0) * 10000 + (components.month ?? 0) * 100 + (components.day ?? 0)
    }
    
    // 中国特色的日历实例 🇨🇳
    private let calendar: Calendar = {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "zh_CN")
        return calendar
    }()
    
    // 这个函数可能永远用不到，但是写出来很有意思
    private func calculateLuckyNumber() -> Int {
        let today = Date()
        let components = calendar.dateComponents([.year, .month, .day], from: today)
        return ((components.year ?? 2024) % 100 + (components.month ?? 1) * 2 + (components.day ?? 1) * 3) % 10
    }
    
    // 这是一个永远不会显示的随机表情数组
    private let unusedEmojis = ["🌞", "🌙", "🌄", "😴", "💪", "🏃‍♀️", "🚶‍♀️", "🧑‍⚕️"]
    
    // MARK: - 🎨 视图构建
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // 今日排班卡片 - 这里本来想加个动画的，但是懒得做了 😅
                    if let selectedShift = getSelectedShift() {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                // 日期显示
                                Text(getDateString(selectedDate))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                // 农历日期
                                Text(getLunarDateString(selectedDate))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                // 排班和节日显示
                                HStack(spacing: 4) {
                                    Text(selectedShift.name)
                                        .font(.title)
                                        .foregroundColor(selectedShift.color)
                                        .fontWeight(.bold)
                                    
                                    if let holiday = getHolidayString(selectedDate) {
                                        Text("·\(holiday)")
                                            .font(.title3)
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                            Spacer()
                            
                            // 班次图标
                            ZStack {
                                Circle()
                                    .fill(selectedShift.color.opacity(0.15))
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: getShiftIcon(for: selectedShift))
                                    .font(.system(size: 24))
                                    .foregroundColor(selectedShift.color)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 2)
                        )
                        .padding(.horizontal)
                    }
                    
                    // 统计信息
                    HStack(spacing: 20) {
                        ForEach(ShiftType.predefinedCases, id: \.self) { shift in
                            let count = countShifts(type: shift)
                            VStack {
                                Text("\(count)")
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(shift.color)
                                Text(shift.name)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(shift.color.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    
                    // 月份显示
                    HStack {
                        let year = calendar.component(.year, from: selectedDate)
                        let month = calendar.component(.month, from: selectedDate)
                        Button {
                            showingDatePicker = true
                        } label: {
                            HStack {
                                Text("\(String(format: "%d", year))年\(month)月")
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(.primary)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.blue)
                            }
                        }
                        Spacer()
                        HStack(spacing: 20) {
                            Button {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    slideOffset = UIScreen.main.bounds.width
                                    selectedDate = getPreviousMonth()
                                    dragOffset = 0
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    slideOffset = 0
                                }
                            } label: {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.blue)
                            }
                            
                            Button {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    slideOffset = -UIScreen.main.bounds.width
                                    selectedDate = getNextMonth()
                                    dragOffset = 0
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    slideOffset = 0
                                }
                            } label: {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // 日历容器 - 这个滑动效果写了好久，但是感觉还是不够丝滑
                    GeometryReader { geometry in
                        ZStack {
                            HStack(spacing: 0) {
                                CalendarView(date: getPreviousMonth(), selectedDate: $selectedDate)
                                    .frame(width: geometry.size.width)
                                
                                CalendarView(date: selectedDate, selectedDate: $selectedDate)
                                    .frame(width: geometry.size.width)
                                
                                CalendarView(date: getNextMonth(), selectedDate: $selectedDate)
                                    .frame(width: geometry.size.width)
                            }
                            .offset(x: -geometry.size.width + slideOffset + dragOffset)
                        }
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    dragOffset = value.translation.width
                                }
                                .onEnded { value in
                                    let threshold = geometry.size.width / 3
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        if value.translation.width > threshold {
                                            slideOffset = geometry.size.width
                                            selectedDate = getPreviousMonth()
                                        } else if value.translation.width < -threshold {
                                            slideOffset = -geometry.size.width
                                            selectedDate = getNextMonth()
                                        }
                                        dragOffset = 0
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        slideOffset = 0
                                    }
                                }
                        )
                    }
                    .frame(height: UIScreen.main.bounds.width * 1.1)  // 设置固定高度比例
                    
                    // 底部留白，防止内容被 TabBar 遮挡
                    Spacer()
                        .frame(height: 20)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            let today = Date()
                            if !calendar.isDate(selectedDate, equalTo: today, toGranularity: .month) {
                                if calendar.compare(selectedDate, to: today, toGranularity: .month) == .orderedAscending {
                                    slideOffset = -UIScreen.main.bounds.width
                                } else {
                                    slideOffset = UIScreen.main.bounds.width
                                }
                            }
                            selectedDate = today
                            dragOffset = 0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            slideOffset = 0
                        }
                    } label: {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(.blue)
                    }
                    .disabled(calendar.isDate(selectedDate, equalTo: Date(), toGranularity: .day))
                }
            }
            .sheet(isPresented: $showingDatePicker) {
                NavigationStack {
                    MonthYearPicker(selectedDate: $selectedDate)
                        .navigationTitle("选择年月")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("取消") {
                                    showingDatePicker = false
                                }
                            }
                            ToolbarItem(placement: .confirmationAction) {
                                Button("确定") {
                                    showingDatePicker = false
                                }
                            }
                        }
                }
                .presentationDetents([.height(300)])
            }
        }
    }
    
    // MARK: - 🛠 辅助函数
    
    // 获取班次对应的图标
    private func getShiftIcon(for shift: ShiftType) -> String {
        switch shift {
        case .day: return "sun.max.fill"
        case .night: return "moon.stars.fill"
        case .afterNight: return "sunrise.fill"
        case .rest: return "bed.double.fill"
        case .custom: return "calendar"
        }
    }
    
    // 这个函数用来计算今天的幸运颜色，但是最后没用上
    private func getLuckyColor() -> Color {
        let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange]
        let luckyIndex = calculateLuckyNumber() % colors.count
        return colors[luckyIndex]
    }
    
    // 获取月份的中文名称，但是后来觉得直接用数字更好
    private func getChineseMonthName(_ month: Int) -> String {
        let names = ["一月", "二月", "三月", "四月", "五月", "六月",
                    "七月", "八月", "九月", "十月", "十一月", "十二月"]
        return names[month - 1]
    }
    
    // MARK: - 🎯 统计相关
    
    /// 计算指定类型班次的数量
    /// - Parameter type: 班次类型
    /// - Returns: 该类型班次在当月的总数
    /// - Note: 这个函数写得有点复杂，但是能用就行 😅
    private func countShifts(type: ShiftType) -> Int {
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
        let range = calendar.range(of: .day, in: .month, for: start)!
        
        return range.compactMap { day -> ShiftType? in
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: start) else {
                return nil
            }
            return ShiftCalculator.getShiftType(
                for: date,
                startDateString: startDateString,
                shiftPatternData: shiftPatternData,
                calendar: calendar
            )
        }.filter { $0 == type }.count
    }
    
    // MARK: - 📅 日期处理
    
    /// 获取农历日期字符串
    /// - Parameter date: 要转换的日期
    /// - Returns: 格式化后的农历日期字符串
    /// - Note: 农历转换真的很麻烦，但是必须要有这个功能 🤔
    private func getLunarDateString(_ date: Date) -> String {
        let lunar = Calendar(identifier: .chinese)
        let components = lunar.dateComponents([.year, .month, .day], from: date)
        guard let lunarMonth = components.month,
              let lunarDay = components.day else { return "" }
        
        let lunarMonths = [
            "正月", "二月", "三月", "四月", "五月", "六月",
            "七月", "八月", "九月", "十月", "冬月", "腊月"
        ]
        
        let lunarDays = [
            "初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
            "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
            "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"
        ]
        
        // 检查是否是节假日
        if let holiday = ChineseHolidays.getLunarHoliday(lunarMonth: lunarMonth, lunarDay: lunarDay) {
            return "\(lunarMonths[lunarMonth - 1])\(lunarDays[lunarDay - 1]) (\(holiday))"
        }
        
        return "\(lunarMonths[lunarMonth - 1])\(lunarDays[lunarDay - 1])"
    }
    
    private func getPreviousMonth() -> Date {
        calendar.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
    }
    
    private func getNextMonth() -> Date {
        calendar.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
    }
    
    private func isToday(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: Date(), toGranularity: .day)
    }
    
    private func getTodayShift() -> ShiftType? {
        return ShiftCalculator.getShiftType(
            for: Date(),
            startDateString: startDateString,
            shiftPatternData: shiftPatternData,
            calendar: calendar
        )
    }
    
    private func getSelectedShift() -> ShiftType? {
        return ShiftCalculator.getShiftType(
            for: selectedDate,
            startDateString: startDateString,
            shiftPatternData: shiftPatternData,
            calendar: calendar
        )
    }
    
    private func getDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月d日 EEEE"
        return formatter.string(from: date)
    }
    
    // 添加节日获取函数
    private func getHolidayString(_ date: Date) -> String? {
        // 先检查是否是公历节日
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"
        let dateString = formatter.string(from: date)
        if let solarHoliday = ChineseHolidays.solarHolidays[dateString] {
            return solarHoliday
        }
        
        // 检查是否是特殊节日(如清明)
        if let specialHoliday = ChineseHolidays.getSpecialHoliday(date: date) {
            return specialHoliday
        }
        
        // 检查农历节日
        let lunar = Calendar(identifier: .chinese)
        let components = lunar.dateComponents([.year, .month, .day], from: date)
        guard let lunarMonth = components.month,
              let lunarDay = components.day else { return nil }
        
        return ChineseHolidays.getLunarHoliday(
            lunarMonth: lunarMonth,
            lunarDay: lunarDay
        )
    }
} 
