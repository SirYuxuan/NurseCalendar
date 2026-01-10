import SwiftUI

struct InsulinCalculatorView: View {
    @State private var units: Double = 0
    @State private var unitsText: String = "0"
    @FocusState private var isInputFocused: Bool

    // 常见剂量的快速参考
    private let commonDoses = [1, 2, 4, 6, 8, 10, 12, 16, 20, 24, 30, 40]

    private var calculatedML: Double {
        units * 0.025
    }

    private var formattedML: String {
        let ml = calculatedML
        if ml.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", ml)
        } else if (ml * 10).truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.1f", ml)
        } else if (ml * 100).truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.2f", ml)
        } else {
            return String(format: "%.3f", ml)
        }
    }

    var body: some View {
        Form {
            Section("实时换算") {
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        Text("胰岛素剂量")
                            .font(.subheadline)

                        Spacer()

                        Button {
                            if units > 0 {
                                units -= 1
                                unitsText = String(format: "%.0f", units)
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)

                        TextField("0", text: $unitsText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.center)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.purple)
                            .frame(width: 60)
                            .focused($isInputFocused)
                            .onChange(of: unitsText) { oldValue, newValue in
                                if let value = Double(newValue) {
                                    units = value
                                } else if newValue.isEmpty {
                                    units = 0
                                }
                            }

                        Button {
                            units += 1
                            unitsText = String(format: "%.0f", units)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                        }
                        .buttonStyle(.plain)

                        Text("IU")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    if units > 0 {
                        Divider()

                        HStack {
                            HStack(spacing: 8) {
                                Image(systemName: "equal.circle.fill")
                                    .foregroundColor(.blue)
                                Text("对应容量")
                                    .font(.subheadline)
                            }

                            Spacer()

                            Text(formattedML)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.blue)

                            Text("ml")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 8)
            }

            Section("常用剂量参考") {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    ForEach(commonDoses, id: \.self) { dose in
                        Button {
                            units = Double(dose)
                            unitsText = String(format: "%.0f", units)
                        } label: {
                            DoseCard(units: dose)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }

            Section {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text("换算公式")
                            .font(.caption)
                            .fontWeight(.medium)
                    }

                    Text("1 IU (单位) = 0.025 ml")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Section {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text("注意事项")
                            .font(.caption)
                            .fontWeight(.medium)
                    }

                    Text("请严格遵医嘱执行，使用前核对患者信息和剂量。")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("胰岛素剂量换算")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("完成") {
                    isInputFocused = false
                }
            }
        }
    }
}

struct DoseCard: View {
    let units: Int

    private var ml: Double {
        Double(units) * 0.025
    }

    private var formattedML: String {
        if ml.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", ml)
        } else if (ml * 10).truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.1f", ml)
        } else if (ml * 100).truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.2f", ml)
        } else {
            return String(format: "%.3f", ml)
        }
    }

    var body: some View {
        VStack(spacing: 2) {
            Text("\(units) IU")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.purple)

            Text("\(formattedML) ml")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.purple.opacity(0.08))
        )
    }
}
