import Foundation

class ShiftDataManager {
    static let shared = ShiftDataManager()
    private let userDefaults = UserDefaults(suiteName: "group.com.yuxuan.nursecalendar")
    
    private init() {}
    
    func saveShift(_ shift: ShiftType, for date: Date) {
        let dateString = formatDate(date)
        if let shiftData = try? JSONEncoder().encode(shift) {
            userDefaults?.set(shiftData, forKey: dateString)
        }
    }
    
    func getShift(for date: Date) -> ShiftType? {
        let dateString = formatDate(date)
        guard let shiftData = userDefaults?.data(forKey: dateString),
              let shift = try? JSONDecoder().decode(ShiftType.self, from: shiftData) else {
            return nil
        }
        return shift
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
} 