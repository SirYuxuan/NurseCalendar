import SwiftUI
import Foundation

struct ContentView: View {
    @State private var selectedTab = 0
    @AppStorage("hasShownDisclaimer") private var hasShownDisclaimer = false
    @State private var showingDisclaimer = false

    var body: some View {
        TabView(selection: $selectedTab) {
            ShiftView()
                .tabItem {
                    Label("排班", systemImage: "calendar")
                }
                .tag(0)

            ToolsView()
                .tabItem {
                    Label("工具", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .tint(.blue)
        .onAppear {
            if !hasShownDisclaimer {
                showingDisclaimer = true
            }
        }
        .alert("免责声明", isPresented: $showingDisclaimer) {
            Button("我已了解") {
                hasShownDisclaimer = true
            }
        } message: {
            Text("本应用仅用于辅助排班和提醒，不能替代专业医疗判断。\n\n使用本应用时请确保遵医嘱执行。")
        }
    }
}
