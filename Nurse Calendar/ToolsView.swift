import SwiftUI

struct ToolsView: View {
    private let appStoreID = "6739861537"

    var body: some View {
        NavigationStack {
            List {
                Section("医疗计算") {
                    NavigationLink(destination: InsulinCalculatorView()) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("胰岛素换算")
                                Text("IU 单位与 ml 容量")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "cross.fill")
                                .foregroundColor(.purple)
                        }
                    }

                    NavigationLink(destination: BMICalculatorView()) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("BMI 计算")
                                Text("体质指数评估")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "scalemass.fill")
                                .foregroundColor(.blue)
                        }
                    }

                    NavigationLink(destination: HeartRateCalculatorView()) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("心率计算")
                                Text("最大心率与目标心率")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                        }
                    }
                }

                Section("单位转换") {
                    NavigationLink(destination: TemperatureConverterView()) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("体温转换")
                                Text("摄氏度 / 华氏度 / 开尔文")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "thermometer")
                                .foregroundColor(.orange)
                        }
                    }
                }

                Section("护理工具") {
                    NavigationLink(destination: MedicalAbbreviationView()) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("医嘱缩写")
                                Text("常用医嘱缩写查询")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "doc.text.magnifyingglass")
                                .foregroundColor(.green)
                        }
                    }
                }

                Section("关于") {
                    Button {
                        openAppStoreReview()
                    } label: {
                        HStack {
                            Label {
                                Text("评价与反馈")
                                    .foregroundColor(.primary)
                            } icon: {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.orange)
                            }
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section {
                    Text("本工具仅供参考，不能替代专业医疗建议。使用前请咨询医生或专业医护人员。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("工具")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func openAppStoreReview() {
        if let url = URL(string: "https://apps.apple.com/app/id\(appStoreID)?action=write-review") {
            UIApplication.shared.open(url)
        }
    }
}
