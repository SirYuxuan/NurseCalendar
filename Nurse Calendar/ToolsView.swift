import SwiftUI

struct ToolCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let destination: AnyView

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color.opacity(0.15))
                        .frame(width: 36, height: 36)

                    Image(systemName: icon)
                        .font(.body)
                        .foregroundColor(color)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()
            }
            .padding(.vertical, 2)
        }
    }
}

struct ToolsView: View {
    // 替换为你的实际 App ID
    private let appStoreID = "YOUR_APP_ID"

    var body: some View {
        NavigationStack {
            List {
                Section("医疗计算") {
                    ToolCard(
                        icon: "cross.fill",
                        title: "胰岛素换算",
                        subtitle: "IU 单位与 ml 容量换算",
                        color: .purple,
                        destination: AnyView(InsulinCalculatorView())
                    )

                    ToolCard(
                        icon: "scalemass.fill",
                        title: "BMI 计算",
                        subtitle: "体质指数评估",
                        color: .blue,
                        destination: AnyView(BMICalculatorView())
                    )

                    ToolCard(
                        icon: "heart.fill",
                        title: "心率计算",
                        subtitle: "最大心率与目标心率",
                        color: .red,
                        destination: AnyView(HeartRateCalculatorView())
                    )
                }

                Section("单位转换") {
                    ToolCard(
                        icon: "thermometer",
                        title: "体温转换",
                        subtitle: "摄氏度 / 华氏度 / 开尔文",
                        color: .orange,
                        destination: AnyView(TemperatureConverterView())
                    )
                }

                Section("护理工具") {
                    ToolCard(
                        icon: "doc.text.magnifyingglass",
                        title: "医嘱缩写",
                        subtitle: "常用医嘱缩写查询",
                        color: .green,
                        destination: AnyView(MedicalAbbreviationView())
                    )
                }

                Section("关于应用") {
                    Button {
                        openAppStoreReview()
                    } label: {
                        HStack(spacing: 10) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.orange.opacity(0.15))
                                    .frame(width: 36, height: 36)

                                Image(systemName: "star.fill")
                                    .font(.body)
                                    .foregroundColor(.orange)
                            }

                            VStack(alignment: .leading, spacing: 1) {
                                Text("评价与反馈")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)

                                Text("在 App Store 为我们评分")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }

                            Spacer()

                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                    .buttonStyle(.plain)
                }

                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                            Text("免责声明")
                                .font(.caption)
                                .fontWeight(.medium)
                        }

                        Text("本工具仅供参考，不能替代专业医疗建议。使用前请咨询医生或专业医护人员。")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("工具")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func openAppStoreReview() {
        // 方式1: 直接打开 App Store 评价页面（需要替换 YOUR_APP_ID）
        if let url = URL(string: "https://apps.apple.com/app/id\(appStoreID)?action=write-review") {
            UIApplication.shared.open(url)
        }
    }
}