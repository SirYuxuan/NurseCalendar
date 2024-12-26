import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("通知权限获取成功")
            }
        }
    }
    
    func scheduleShiftNotification(for date: Date, shift: ShiftType) {
        let content = UNMutableNotificationContent()
        content.title = "排班提醒"
        content.body = "明天是\(shift.name)，请做好准备"
        content.sound = .default
        
        // 设置在前一天晚上8点提醒
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = 20
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: date.ISO8601Format(), content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
} 