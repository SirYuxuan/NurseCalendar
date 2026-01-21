import Foundation

// App Group 标识符
let appGroupIdentifier = "group.com.yuxuan.nursecalendar"

// 共享数据管理器
struct SharedDataManager {
    static let shared = SharedDataManager()

    private let userDefaults: UserDefaults?

    private init() {
        userDefaults = UserDefaults(suiteName: appGroupIdentifier)
    }

    // 同步排班数据到 App Group
    func syncShiftData(startDateString: String, shiftPatternData: Data, weekStartsOnMonday: Bool) {
        userDefaults?.set(startDateString, forKey: "startDate")
        userDefaults?.set(shiftPatternData, forKey: "shiftPattern")
        userDefaults?.set(weekStartsOnMonday, forKey: "weekStartsOnMonday")
        userDefaults?.synchronize()
    }

    // 读取排班数据
    func getStartDateString() -> String? {
        return userDefaults?.string(forKey: "startDate")
    }

    func getShiftPatternData() -> Data? {
        return userDefaults?.data(forKey: "shiftPattern")
    }

    func getWeekStartsOnMonday() -> Bool {
        return userDefaults?.bool(forKey: "weekStartsOnMonday") ?? false
    }
}
