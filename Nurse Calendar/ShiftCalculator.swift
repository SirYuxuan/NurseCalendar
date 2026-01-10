import Foundation

struct ShiftCalculator {
    private static let iso8601Formatter = ISO8601DateFormatter()
    private static let jsonDecoder = JSONDecoder()

    // 缓存解析结果
    private static var cachedStartDate: (string: String, date: Date)?
    private static var cachedPattern: (data: Data, pattern: [ShiftType])?

    static func getShiftType(for date: Date, startDateString: String, shiftPatternData: Data, calendar: Calendar = .current) -> ShiftType? {
        // 使用缓存的起始日期
        let startDate: Date
        if let cached = cachedStartDate, cached.string == startDateString {
            startDate = cached.date
        } else {
            guard let parsed = iso8601Formatter.date(from: startDateString) else {
                return nil
            }
            cachedStartDate = (startDateString, parsed)
            startDate = parsed
        }

        // 使用缓存的排班模式
        let shiftPattern: [ShiftType]
        if let cached = cachedPattern, cached.data == shiftPatternData {
            shiftPattern = cached.pattern
        } else {
            guard let decoded = try? jsonDecoder.decode([ShiftType].self, from: shiftPatternData),
                  !decoded.isEmpty else {
                return nil
            }
            cachedPattern = (shiftPatternData, decoded)
            shiftPattern = decoded
        }

        let startDay = calendar.startOfDay(for: startDate)
        let targetDay = calendar.startOfDay(for: date)
        let days = calendar.dateComponents([.day], from: startDay, to: targetDay).day ?? 0
        let patternLength = shiftPattern.count
        let normalizedDays = ((days % patternLength) + patternLength) % patternLength

        return shiftPattern[normalizedDays]
    }
} 