import SwiftUI

struct BMICalculatorView: View {
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var bmi: Double?
    @State private var bmiCategory: String = ""
    @State private var bmiColor: Color = .black
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            Form {
                Section(header: Text("输入信息")) {
                    TextField("体重 (kg)", text: $weight)
                        .keyboardType(.decimalPad)
                    TextField("身高 (cm)", text: $height)
                        .keyboardType(.decimalPad)
                }
                
                Button("计算 BMI") {
                    calculateBMI()
                }
                
                if let bmi = bmi {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("您的 BMI 是 \(String(format: "%.2f", bmi))")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(bmiColor)
                        Text("分类: \(bmiCategory)")
                            .font(.title2)
                            .foregroundColor(bmiColor)
                    }
                    .padding()
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }

                Section(header: Text("参考资料")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("BMI 计算公式和分类标准参考以下权威来源：")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Link("世界卫生组织 (WHO) - BMI 分类标准", destination: URL(string: "https://www.who.int/health-topics/obesity")!)
                            .font(.caption)

                        Link("中国卫生健康委员会 - 成人体重判定", destination: URL(string: "http://www.nhc.gov.cn/")!)
                            .font(.caption)

                        Text("计算公式：BMI = 体重(kg) / 身高²(m)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("BMI 计算器")
        }
    }
    
    private func calculateBMI() {
        guard let weight = Double(weight), let height = Double(height), height > 0 else {
            errorMessage = "请输入有效的体重和身高。"
            bmi = nil
            return
        }
        
        errorMessage = nil
        print("Weight: \(weight), Height: \(height)")
        bmi = weight / ((height / 100) * (height / 100))
        updateBMICategory()
    }
    
    private func updateBMICategory() {
        guard let bmi = bmi else { return }
        
        switch bmi {
        case ..<18.5:
            bmiCategory = "体重过轻"
            bmiColor = .blue
        case 18.5..<24.9:
            bmiCategory = "正常"
            bmiColor = .green
        case 25..<29.9:
            bmiCategory = "超重"
            bmiColor = .orange
        default:
            bmiCategory = "肥胖"
            bmiColor = .red
        }
    }
} 