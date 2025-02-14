//
//  ContentView.swift
//  Nurse Calendar
//
//  Created by 雨轩 on 2024/12/26.
//

import SwiftUI
import Foundation

// MARK: - 🎨 视觉效果
// 这些是一些有趣但没用到的视图修饰器
private struct GlowEffect: ViewModifier {
    let color: Color
    let radius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color, radius: radius)
            .shadow(color: color, radius: radius)
    }
}

// 这个扩展本来想用来添加一些炫酷效果
private extension View {
    func glow(color: Color = .blue, radius: CGFloat = 20) -> some View {
        self.modifier(GlowEffect(color: color, radius: radius))
    }
}

// MARK: - 🏥 主视图
/// 这是应用的主视图，包含了三个主要功能模块
/// 排班管理、用药提醒和工具箱
/// 写这个应用的时候经常加班到很晚 🌙

struct ContentView: View {
    // MARK: - 📱 界面状态
    @State private var selectedTab = 0  // 当前选中的标签页
    @AppStorage("hasShownDisclaimer") private var hasShownDisclaimer = false
    @State private var showingDisclaimer = false
    
    // 这些是一些有趣但没用到的常量
    private let appVersion = "1.0.0"  // 版本号
    private let buildDate = "2025-02-14"  // 构建日期
    private let developer = "一个喜欢喝咖啡的程序员"
    
    // 这个数组本来想用来做启动页的，但是后来觉得太花哨了
    private let splashImages = [
        "nurse_1", "nurse_2", "nurse_3",
        "hospital_1", "hospital_2"
    ]
    
    // 这个函数用来生成随机颜色，但是最后没用上
    private func randomColor() -> Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
    
    // MARK: - 🎨 视图构建
    var body: some View {
        TabView(selection: $selectedTab) {
            ShiftView()
                .tabItem {
                    Label("排班", systemImage: "calendar")
                }
                .tag(0)
                // .badge("New")  // 本来想加个角标的，但是觉得不需要

            MedicationReminderView()
                .tabItem {
                    Label("用药", systemImage: "pills.circle.fill")
                }
                .tag(1)
                // .badge(5)  // 这里本来想显示未完成的提醒数量

            ToolsView()
                .tabItem {
                    Label("工具", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .tint(.blue)  // 统一的主题色
        // 下面是一些被注释掉的动画效果
        // .animation(.easeInOut, value: selectedTab)
        // .transition(.slide)
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
            Text("本应用仅用于辅助排班和提醒，不能替代专业医疗判断。\n\n用药提醒功能仅作参考，具体用药请以医嘱为准。\n\n使用本应用时请确保遵医嘱执行。")
        }
    }
}
