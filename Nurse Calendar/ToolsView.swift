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
                            VStack(alignment: .leading) {
                                Text("BMI 计算器")
                                Text("世界卫生组织标准")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    NavigationLink(destination: HeartRateCalculatorView()) {
                        HStack {
                            Image(systemName: "heart")
                                .foregroundColor(.red)
                            VStack(alignment: .leading) {
                                Text("心率计算器")
                                Text("基于 Tanaka 和 Gulati 公式")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    NavigationLink(destination: TemperatureConverterView()) {
                        HStack {
                            Image(systemName: "thermometer")
                                .foregroundColor(.orange)
                            VStack(alignment: .leading) {
                                Text("体温转换器")
                                Text("基于国际温标")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                Section(header: Text("参考来源")) {
                    Link(destination: URL(string: "https://www.who.int/news-room/fact-sheets/detail/obesity-and-overweight")!) {
                        HStack {
                            Text("BMI 分类标准")
                            Spacer()
                            Image(systemName: "link")
                        }
                    }
                    
                    Link(destination: URL(string: "https://pubmed.ncbi.nlm.nih.gov/11153730/")!) {
                        HStack {
                            Text("Tanaka 心率公式")
                            Spacer()
                            Image(systemName: "link")
                        }
                    }
                    
                    Link(destination: URL(string: "https://pubmed.ncbi.nlm.nih.gov/20585008/")!) {
                        HStack {
                            Text("Gulati 心率公式")
                            Spacer()
                            Image(systemName: "link")
                        }
                    }
                    
                    Link(destination: URL(string: "https://www.bipm.org/en/measurement-units/si-base-units")!) {
                        HStack {
                            Text("国际温标")
                            Spacer()
                            Image(systemName: "link")
                        }
                    }
                }
                
                Section(header: Text("计算公式")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("BMI = 体重(kg) / 身高(m)²")
                            .font(.caption)
                        Text("来源: WHO 1995")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("最大心率 (Tanaka) = 208 - 0.7 × 年龄")
                            .font(.caption)
                        Text("来源: Tanaka et al., 2001")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("最大心率 (Gulati) = 206 - 0.88 × 年龄")
                            .font(.caption)
                        Text("来源: Gulati et al., 2010")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("°F = °C × 9/5 + 32")
                        Text("K = °C + 273.15")
                            .font(.caption)
                        Text("来源: 国际度量衡局")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("工具")
        }
    }
} 