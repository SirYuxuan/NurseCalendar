import SwiftUI
import Foundation
import StoreKit

struct ContentView: View {
    @State private var selectedTab = 0
    @AppStorage("hasShownDisclaimer") private var hasShownDisclaimer = false
    @AppStorage("appLaunchCount") private var appLaunchCount = 0
    @AppStorage("hasRequestedReview") private var hasRequestedReview = false
    @State private var showingDisclaimer = false
    @StateObject private var alarmPlayer = AlarmPlayer.shared
    @Environment(\.requestReview) var requestReview

    var body: some View {
        ZStack {
        TabView(selection: $selectedTab) {
            ShiftView()
                .tabItem {
                    Label("排班", systemImage: "calendar")
                }
                .tag(0)

            AlarmView()
                .tabItem {
                    Label("闹钟", systemImage: "alarm.fill")
                }
                .tag(1)

            ToolsView()
                .tabItem {
                    Label("工具", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .tint(.blue)
        .onAppear {
            // 增加启动计数
            appLaunchCount += 1

            // 显示免责声明
            if !hasShownDisclaimer {
                showingDisclaimer = true
            }

            // 在第 10 次启动时请求评价
            if appLaunchCount == 10 && !hasRequestedReview {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    requestReview()
                    hasRequestedReview = true
                }
            }
        }
        .alert("免责声明", isPresented: $showingDisclaimer) {
            Button("我已了解") {
                hasShownDisclaimer = true
            }
        } message: {
            Text("本应用仅用于辅助排班和提醒，不能替代专业医疗判断。\n\n使用本应用时请确保遵医嘱执行。")
        }

            // 全屏闹钟响铃界面
            if alarmPlayer.isRinging, let alarm = alarmPlayer.currentAlarm {
                AlarmRingingView(alarm: alarm) {
                    alarmPlayer.stopAlarm()
                }
                .transition(.move(edge: .bottom))
                .zIndex(999)
            }
        }
    }
}
