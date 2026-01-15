import SwiftUI
import Foundation

struct TodayShiftCard: View {
    let date: Date
    let shift: ShiftType
    let dateString: String
    let lunarString: String
    let holiday: String?

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(dateString)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(lunarString)
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 6) {
                    Text(shift.name)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(shift.color)

                    if let holiday = holiday {
                        Text("· \(holiday)")
                            .font(.title3)
                            .foregroundColor(.red)
                    }
                }
            }

            Spacer()

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [shift.color.opacity(0.3), shift.color.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)

                Image(systemName: getShiftIcon(for: shift))
                    .font(.system(size: 28))
                    .foregroundColor(shift.color)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: shift.color.opacity(0.15), radius: 15, x: 0, y: 5)
        )
        .padding(.horizontal, 16)
    }

    private func getShiftIcon(for shift: ShiftType) -> String {
        switch shift {
        case .day: return "sun.max.fill"
        case .night: return "moon.stars.fill"
        case .afterNight: return "sunrise.fill"
        case .rest: return "bed.double.fill"
        case .custom: return "calendar"
        }
    }
}

struct MonthlyStatsView: View {
    let stats: [(shift: ShiftType, count: Int)]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(stats, id: \.shift) { item in
                VStack(spacing: 2) {
                    Text("\(item.count)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(item.shift.color)

                    Text(item.shift.name)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(item.shift.color.opacity(0.08))
                )
            }
        }
        .padding(.horizontal, 16)
    }
}

struct ShiftView: View {
    @State private var selectedDate = Date()
    @State private var currentMonthOffset = 0
    @AppStorage("startDate") private var startDateString: String = Date().ISO8601Format()
    @AppStorage("shiftPattern") private var shiftPatternData: Data = try! JSONEncoder().encode(ShiftType.defaultPattern)
    @State private var showingDatePicker = false

    private var shouldShowExtraInfo: Bool {
        UIScreen.main.bounds.height > 700
    }

    private let calendar: Calendar = {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "zh_CN")
        return calendar
    }()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        if shouldShowExtraInfo, let selectedShift = getSelectedShift() {
                            TodayShiftCard(
                                date: selectedDate,
                                shift: selectedShift,
                                dateString: getDateString(selectedDate),
                                lunarString: getLunarDateString(selectedDate),
                                holiday: getHolidayString(selectedDate)
                            )
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            ))
                        }

                        if shouldShowExtraInfo {
                            MonthlyStatsView(
                                stats: ShiftType.predefinedCases.map { shift in
                                    (shift: shift, count: countShifts(type: shift))
                                }
                            )
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        VStack(spacing: 12) {
                            HStack {
                                let year = calendar.component(.year, from: selectedDate)
                                let month = calendar.component(.month, from: selectedDate)
                                Button {
                                    showingDatePicker = true
                                } label: {
                                    HStack(spacing: 6) {
                                        Text(String(format: "%d年%d月", year, month))
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(.primary)
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.blue)
                                    }
                                }

                                Spacer()

                                HStack(spacing: 16) {
                                    Button {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            selectedDate = getPreviousMonth()
                                        }
                                    } label: {
                                        Image(systemName: "chevron.left.circle.fill")
                                            .font(.system(size: 28))
                                            .foregroundColor(.blue)
                                    }

                                    Button {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            selectedDate = getNextMonth()
                                        }
                                    } label: {
                                        Image(systemName: "chevron.right.circle.fill")
                                            .font(.system(size: 28))
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)

                            GeometryReader { geometry in
                                TabView(selection: $currentMonthOffset) {
                                    CalendarView(date: getPreviousMonth(), selectedDate: $selectedDate)
                                        .tag(-1)

                                    CalendarView(date: selectedDate, selectedDate: $selectedDate)
                                        .tag(0)

                                    CalendarView(date: getNextMonth(), selectedDate: $selectedDate)
                                        .tag(1)
                                }
                                .tabViewStyle(.page(indexDisplayMode: .never))
                                .onChange(of: currentMonthOffset) { oldValue, newValue in
                                    if newValue == -1 {
                                        selectedDate = getPreviousMonth()
                                        currentMonthOffset = 0
                                    } else if newValue == 1 {
                                        selectedDate = getNextMonth()
                                        currentMonthOffset = 0
                                    }
                                }
                            }
                            .frame(height: 520)
                        }

                        Spacer()
                            .frame(height: 20)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.blue)
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        let today = Date()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedDate = today
                        }
                        currentMonthOffset = 0
                    } label: {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(.blue)
                    }
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
                                    currentMonthOffset = 0
                                }
                            }
                        }
                }
                .presentationDetents([.height(300)])
            }
        }
    }

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

    private func getHolidayString(_ date: Date) -> String? {
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

    private func getCalendarHeight() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height

        // 判断是否是 iPad
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad

        if isIPad {
            // iPad: 计算实际需要的高度
            // 星期头部：40 (padding 8*2 + 文字约24)
            // 6行日期：6 × 58 = 348
            // 行间距：5 × 8 = 40
            // 上下间距：20 + 20 = 40
            // 总计：约 468，留一些余量 = 480
            return 480
        } else {
            // iPhone: 使用原来的比例
            return screenWidth * 1.1
        }
    }
}
