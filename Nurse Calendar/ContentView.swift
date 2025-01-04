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

            StudyView()
                .tabItem {
                    Image(systemName: "book")
                    Text("学习")
                }
                .tag(1)

            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("我的")
                }
                .tag(2)
        }
    }
}
