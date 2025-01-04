import SwiftUI

struct TemperatureConverterView: View {
    @State private var celsius: String = ""
    @State private var fahrenheit: String = ""
    @State private var kelvin: String = ""
    @State private var selectedUnit: String = "摄氏度"
    @State private var temperatureStatus: String = ""
    @State private var statusColor: Color = .black

    let units = ["摄氏度", "华氏度", "开尔文"]

    var body: some View {
        Form {
            Section(header: Text("温度输入")) {
                Picker("选择单位", selection: $selectedUnit) {
                    ForEach(units, id: \.self) { unit in
                        Text(unit).tag(unit)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: selectedUnit) { oldValue, newValue in
                    convertTemperature()
                }

                switch selectedUnit {
                case "摄氏度":
                    TextField("输入温度", text: $celsius)
                        .keyboardType(.decimalPad)
                        .onChange(of: celsius) { oldValue, newValue in
                            if !celsius.isEmpty {
                                convertFromCelsius()
                                checkTemperatureStatus()
                            }
                        }
                case "华氏度":
                    TextField("输入温度", text: $fahrenheit)
                        .keyboardType(.decimalPad)
                        .onChange(of: fahrenheit) { oldValue, newValue in
                            if !fahrenheit.isEmpty {
                                convertFromFahrenheit()
                                checkTemperatureStatus()
                            }
                        }
                case "开尔文":
                    TextField("输入温度", text: $kelvin)
                        .keyboardType(.decimalPad)
                        .onChange(of: kelvin) { oldValue, newValue in
                            if !kelvin.isEmpty {
                                convertFromKelvin()
                                checkTemperatureStatus()
                            }
                        }
                default:
                    EmptyView()
                }
            }

            Section(header: Text("转换结果")) {
                VStack(alignment: .leading, spacing: 10) {
                    if !celsius.isEmpty {
                        HStack {
                            Image(systemName: "thermometer")
                                .foregroundColor(.red)
                            Text("摄氏度: \(celsius) °C")
                        }
                    }
                    if !fahrenheit.isEmpty {
                        HStack {
                            Image(systemName: "thermometer")
                                .foregroundColor(.orange)
                            Text("华氏度: \(fahrenheit) °F")
                        }
                    }
                    if !kelvin.isEmpty {
                        HStack {
                            Image(systemName: "thermometer")
                                .foregroundColor(.blue)
                            Text("开尔文: \(kelvin) K")
                        }
                    }
                }
            }

            if !temperatureStatus.isEmpty {
                Section(header: Text("体温状态")) {
                    HStack {
                        Image(systemName: getStatusIcon())
                            .foregroundColor(statusColor)
                        Text(temperatureStatus)
                            .foregroundColor(statusColor)
                    }
                }
            }

            Section(header: Text("参考信息")) {
                Text("正常体温范围：")
                    .font(.headline)
                Text("• 腋下: 36.2-37.2°C")
                Text("• 口腔: 36.5-37.5°C")
                Text("• 肛门: 36.8-37.8°C")
            }
        }
        .navigationTitle("体温转换器")
    }

    private func convertFromCelsius() {
        guard let celsiusValue = Double(celsius) else { return }
        fahrenheit = String(format: "%.1f", celsiusValue * 9 / 5 + 32)
        kelvin = String(format: "%.1f", celsiusValue + 273.15)
    }

    private func convertFromFahrenheit() {
        guard let fahrenheitValue = Double(fahrenheit) else { return }
        celsius = String(format: "%.1f", (fahrenheitValue - 32) * 5 / 9)
        kelvin = String(format: "%.1f", (fahrenheitValue - 32) * 5 / 9 + 273.15)
    }

    private func convertFromKelvin() {
        guard let kelvinValue = Double(kelvin) else { return }
        celsius = String(format: "%.1f", kelvinValue - 273.15)
        fahrenheit = String(format: "%.1f", (kelvinValue - 273.15) * 9 / 5 + 32)
    }

    private func convertTemperature() {
        switch selectedUnit {
        case "摄氏度":
            if !fahrenheit.isEmpty {
                convertFromFahrenheit()
            } else if !kelvin.isEmpty {
                convertFromKelvin()
            }
        case "华氏度":
            if !celsius.isEmpty {
                convertFromCelsius()
            } else if !kelvin.isEmpty {
                convertFromKelvin()
            }
        case "开尔文":
            if !celsius.isEmpty {
                convertFromCelsius()
            } else if !fahrenheit.isEmpty {
                convertFromFahrenheit()
            }
        default:
            break
        }
    }

    private func checkTemperatureStatus() {
        guard let celsiusValue = Double(celsius) else { return }
        
        switch celsiusValue {
        case ..<35:
            temperatureStatus = "低温"
            statusColor = .blue
        case 35..<36.2:
            temperatureStatus = "偏低"
            statusColor = .cyan
        case 36.2..<37.2:
            temperatureStatus = "正常"
            statusColor = .green
        case 37.2..<38:
            temperatureStatus = "轻微发烧"
            statusColor = .orange
        case 38..<39:
            temperatureStatus = "中度发烧"
            statusColor = .red
        default:
            temperatureStatus = "高烧"
            statusColor = .purple
        }
    }

    private func getStatusIcon() -> String {
        switch temperatureStatus {
        case "低温":
            return "thermometer.snowflake"
        case "偏低":
            return "thermometer.low"
        case "正常":
            return "checkmark.circle"
        case "轻微发烧":
            return "thermometer.medium"
        case "中度发烧":
            return "thermometer.high"
        case "高烧":
            return "exclamationmark.triangle"
        default:
            return "thermometer"
        }
    }
} 