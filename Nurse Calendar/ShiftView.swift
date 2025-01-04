import SwiftUI
import Foundation

struct ShiftView: View {
    @State private var selectedDate = Date()
    @State private var slideOffset: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    @AppStorage("startDate") private var startDateString: String = Date().ISO8601Format()
    @AppStorage("shiftPattern") private var shiftPatternData: Data = try! JSONEncoder().encode(ShiftType.defaultPattern)
    @State private var showingDatePicker = false
    
    private let calendar: Calendar = {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "zh_CN")
        return calendar
    }()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 今日排班卡片
                if let selectedShift = getSelectedShift() {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            // 日期显示
                            Text(getDateString(selectedDate))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            // 农历日期
                            Text(getLunarDateString(selectedDate))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            // 排班和节日显示
                            HStack(spacing: 4) {
                                Text(selectedShift.name)
                                    .font(.title2)
                                    .foregroundColor(selectedShift.color)
                                    .bold()
                                
                                if let holiday = getHolidayString(selectedDate) {
                                    Text("·\(holiday)")
                                        .font(.title3)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        Spacer()
                        Circle()
                            .fill(selectedShift.color.opacity(0.2))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image("hellokitty")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(8)
                                    .foregroundColor(selectedShift.color)
                            )
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
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
                
                // 日历容器
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
    
    private func getPreviousMonth() -> Date {
        calendar.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
    }
    
    private func getNextMonth() -> Date {
        calendar.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
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
