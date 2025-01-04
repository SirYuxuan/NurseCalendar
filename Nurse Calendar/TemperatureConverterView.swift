import SwiftUI

struct TemperatureConverterView: View {
    @State private var celsius: String = ""
    @State private var fahrenheit: String = ""

    var body: some View {
        Form {
            Section(header: Text("摄氏度转华氏度")) {
                TextField("摄氏度", text: $celsius)
                    .keyboardType(.decimalPad)
                Button("转换") {
                    convertToFahrenheit()
                }
                if !fahrenheit.isEmpty {
                    Text("\(fahrenheit) °F")
                }
            }
            
            Section(header: Text("华氏度转摄氏度")) {
                TextField("华氏度", text: $fahrenheit)
                    .keyboardType(.decimalPad)
                Button("转换") {
                    convertToCelsius()
                }
                if !celsius.isEmpty {
                    Text("\(celsius) °C")
                }
            }
        }
        .navigationTitle("体温转换器")
    }
    
    private func convertToFahrenheit() {
        guard let celsiusValue = Double(celsius) else {
            return
        }
        let fahrenheitValue = celsiusValue * 9 / 5 + 32
        fahrenheit = String(format: "%.2f", fahrenheitValue)
    }
    
    private func convertToCelsius() {
        guard let fahrenheitValue = Double(fahrenheit) else {
            return
        }
        let celsiusValue = (fahrenheitValue - 32) * 5 / 9
        celsius = String(format: "%.2f", celsiusValue)
    }
} 