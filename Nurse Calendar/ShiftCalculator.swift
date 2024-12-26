import Foundation

struct ShiftCalculator {
    static func getShiftType(for date: Date, startDateString: String, shiftPatternData: Data, calendar: Calendar = .current) -> ShiftType? {
        guard let startDate = ISO8601DateFormatter().date(from: startDateString) else {
            return nil
        }
        
        guard let shiftPattern = try? JSONDecoder().decode([ShiftType].self, from: shiftPatternData),
              !shiftPattern.isEmpty else {
            return nil
        }
        
        let startDay = calendar.startOfDay(for: startDate)
        let targetDay = calendar.startOfDay(for: date)
        let days = calendar.dateComponents([.day], from: startDay, to: targetDay).day ?? 0
        let patternLength = shiftPattern.count
        let normalizedDays = ((days % patternLength) + patternLength) % patternLength
        
        return shiftPattern[normalizedDays]
    }
} 