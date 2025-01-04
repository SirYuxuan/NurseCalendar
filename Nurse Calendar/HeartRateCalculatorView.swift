import SwiftUI

struct HeartRateCalculatorView: View {
    @State private var age: String = ""
    @State private var maxHeartRate: Int?
    @State private var tanakaMaxHeartRate: Int?
    @State private var gulatiMaxHeartRate: Int?
    @State private var lightIntensity: (min: Int, max: Int)?
    @State private var moderateIntensity: (min: Int, max: Int)?
    @State private var vigorousIntensity: (min: Int, max: Int)?
    @State private var formulaType: String = "标准公式"

    var body: some View {
        Form {
            Section(header: Text("输入信息")) {
                TextField("年龄", text: $age)
                    .keyboardType(.numberPad)
            }
            
            Section(header: Text("选择公式")) {
                Picker("公式类型", selection: $formulaType) {
                    Text("标准公式").tag("标准公式")
                    Text("成年人").tag("Tanaka公式")
                    Text("女性").tag("Gulati公式")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Button("计算心率") {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                calculateHeartRate()
            }
            
            if let maxHeartRate = maxHeartRate {
                Section(header: Text("结果")) {
                    Text("最大心率是 \(maxHeartRate) bpm")
                    if let light = lightIntensity {
                        Text("轻度运动心率范围: \(light.min) - \(light.max) bpm")
                    }
                    if let moderate = moderateIntensity {
                        Text("中度运动心率范围: \(moderate.min) - \(moderate.max) bpm")
                    }
                    if let vigorous = vigorousIntensity {
                        Text("剧烈运动心率范围: \(vigorous.min) - \(vigorous.max) bpm")
                    }
                }
            }
            
            if let tanakaMaxHeartRate = tanakaMaxHeartRate {
                Text("Tanaka公式最大心率: \(tanakaMaxHeartRate) bpm")
            }
            if let gulatiMaxHeartRate = gulatiMaxHeartRate {
                Text("Gulati公式最大心率: \(gulatiMaxHeartRate) bpm")
            }
        }
        .navigationTitle("心率计算器")
        .onChange(of: formulaType) { _ in
            if !age.isEmpty {
                calculateHeartRate()
            }
        }
    }
    
    private func calculateHeartRate() {
        guard let age = Int(age) else {
            return
        }
        
        switch formulaType {
        case "标准公式":
            maxHeartRate = 220 - age
        case "Tanaka公式":
            maxHeartRate = Int(208 - 0.7 * Double(age))
        case "Gulati公式":
            maxHeartRate = Int(206 - 0.88 * Double(age))
        default:
            maxHeartRate = nil
        }
        
        lightIntensity = (min: Int(Double(maxHeartRate!) * 0.5), max: Int(Double(maxHeartRate!) * 0.6))
        moderateIntensity = (min: Int(Double(maxHeartRate!) * 0.6), max: Int(Double(maxHeartRate!) * 0.7))
        vigorousIntensity = (min: Int(Double(maxHeartRate!) * 0.7), max: Int(Double(maxHeartRate!) * 0.85))
    }
} 