//
//  Nurse_CalendarApp.swift
//  Nurse Calendar
//
//  Created by 雨轩 on 2024/12/26.
//

import SwiftUI
import UserNotifications

// 通知代理 - 处理前台通知
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    private override init() {
        super.init()
    }

    // 当通知将要在前台展示时调用
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("📱 前台收到通知: \(notification.request.content.title)")

        // 创建闹钟对象
        let alarm = AlarmItem(
            id: notification.request.identifier,
            title: notification.request.content.title,
            fireDate: Date(),
            type: notification.request.content.title == "皮试提醒" ? .skinTest : .custom
        )

        // 触发闹钟
        DispatchQueue.main.async {
            AlarmPlayer.shared.triggerAlarm(alarm)
        }

        // 不显示系统通知横幅（因为我们有自己的全屏界面）
        completionHandler([])
    }
}

@main
struct Nurse_CalendarApp: App {
    init() {
        // 设置通知代理
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
