//
//  ContentView.swift
//  Nurse Calendar
//
//  Created by 雨轩 on 2024/12/26.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ShiftView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("排班")
                }
                .tag(0)

            MedicationReminderView()
                .tabItem {
                    Image(systemName: "pills")
                    Text("用药")
                }
                .tag(1)

            ToolsView()
                .tabItem {
                    Image(systemName: "wrench.and.screwdriver")
                    Text("工具")
                }
                .tag(2)
        }
    }
}
