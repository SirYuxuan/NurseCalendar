import Foundation

struct ChineseHolidays {
    // 公历节日
    static let solarHolidays: [String: String] = [
        "01-01": "元旦",
        "02-14": "情人节",
        "03-08": "妇女节",
        "04-01": "愚人节",
        "05-01": "劳动节",
        "06-01": "儿童节",
        "07-01": "建党节",
        "08-01": "建军节",
        "09-10": "教师节",
        "10-01": "国庆节",
        "12-24": "平安夜",
        "12-25": "圣诞节"
    ]
    
    // 农历节日
    static func getLunarHoliday(lunarMonth: Int, lunarDay: Int) -> String? {
        switch (lunarMonth, lunarDay) {
        case (1, 1): return "春节"
        case (1, 15): return "元宵"
        case (5, 5): return "端午"
        case (7, 7): return "七夕"
        case (8, 15): return "中秋"
        case (9, 9): return "重阳"
        default: return nil
        }
    }
    
    // 特殊节日(如清明节等需要专门计算)
    static func getSpecialHoliday(date: Date) -> String? {
        let solarTerms = SolarTerms(date: date)
        if solarTerms.isQingMing {
            return "清明"
        }
        return nil
    }
}

// 处理二十四节气
struct SolarTerms {
    let date: Date
    
    // 2024-2026年的清明节日期
    private static let qingMingDates: [String: Int] = [
        "2024": 4,  // 2024年4月4日
        "2025": 4,  // 2025年4月4日
        "2026": 5   // 2026年4月5日
    ]
    
    var isQingMing: Bool {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        guard let year = components.year,
              let month = components.month,
              let day = components.day else { return false }
        
        // 只在4月判断
        guard month == 4 else { return false }
        
        // 获取该年的清明节日期
        if let qingMingDay = Self.qingMingDates[String(year)] {
            return day == qingMingDay
        }
        
        // 如果没有预设数据，使用默认值（4月4日）
        return day == 4
    }
} 