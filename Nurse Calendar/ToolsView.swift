import SwiftUI

struct ToolsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("常用工具")) {
                    NavigationLink(destination: BMICalculatorView()) {
                        HStack {
                            Image(systemName: "scalemass")
                                .foregroundColor(.blue)
                            Text("BMI 计算器")
                        }
                    }
                    
                    NavigationLink(destination: HeartRateCalculatorView()) {
                        HStack {
                            Image(systemName: "heart")
                                .foregroundColor(.red)
                            Text("心率计算器")
                        }
                    }
                    
                    NavigationLink(destination: TemperatureConverterView()) {
                        HStack {
                            Image(systemName: "thermometer")
                                .foregroundColor(.orange)
                            Text("体温转换器")
                        }
                    }
                }
            }
            .navigationTitle("工具")
        }
    }
} 