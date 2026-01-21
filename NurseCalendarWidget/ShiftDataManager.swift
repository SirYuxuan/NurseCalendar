import Foundation
import WidgetKit

class ShiftDataManager {
    static let shared = ShiftDataManager()
    private let userDefaults = UserDefaults(suiteName: "group.com.yuxuan.nursecalendar")

    private init() {}

    // 根据日期计算排班（使用循环模式）
    func getShift(for date: Date) -> ShiftType? {
        guard let startDateString = userDefaults?.string(forKey: "startDate"),
              let shiftPatternData = userDefaults?.data(forKey: "shiftPattern"),
              let startDate = ISO8601DateFormatter().date(from: startDateString),
              let shiftPattern = try? JSONDecoder().decode([ShiftType].self, from: shiftPatternData),
              !shiftPattern.isEmpty else {
            return nil
        }

        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: startDate)
        let targetDay = calendar.startOfDay(for: date)
        let days = calendar.dateComponents([.day], from: startDay, to: targetDay).day ?? 0
        let patternLength = shiftPattern.count
        let normalizedDays = ((days % patternLength) + patternLength) % patternLength

        return shiftPattern[normalizedDays]
    }

    // 获取每周起始日设置
    func getWeekStartsOnMonday() -> Bool {
        return userDefaults?.bool(forKey: "weekStartsOnMonday") ?? false
    }

    // 当外部数据更新后，调用此方法以通知小组件刷新
    func reloadWidgets() {
        // 优先按 widget kind 精确刷新
        WidgetCenter.shared.reloadTimelines(ofKind: "ShiftWidget")
        // 作为兜底，刷新所有小组件
        WidgetCenter.shared.reloadAllTimelines()
    }
}
