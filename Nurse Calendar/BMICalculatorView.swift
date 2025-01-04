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