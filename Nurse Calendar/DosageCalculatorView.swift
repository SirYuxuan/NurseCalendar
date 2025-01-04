import SwiftUI

struct DosageCalculatorView: View {
    @State private var weight: String = ""
    @State private var age: String = ""
    @State private var bsa: String = ""
    @State private var concentration: String = ""
    @State private var dosageType: String = "Ibuprofen Adult"
    @State private var dosage: Double?

    var body: some View {
        Form {
            Section(header: Text("输入信息")) {
                TextField("体重 (kg)", text: $weight)
                    .keyboardType(.decimalPad)
                TextField("年龄 (月)", text: $age)
                    .keyboardType(.numberPad)
                TextField("体表面积 (m²)", text: $bsa)
                    .keyboardType(.decimalPad)
                TextField("药物浓度 (mg/mL)", text: $concentration)
                    .keyboardType(.decimalPad)
                Picker("剂量类型", selection: $dosageType) {
                    Text("布洛芬 成人").tag("Ibuprofen Adult")
                    Text("布洛芬 儿童").tag("Ibuprofen Child")
                    Text("氨茶碱 成人").tag("Theophylline Adult")
                    Text("氨茶碱 儿童").tag("Theophylline Child")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Button("计算剂量") {
                calculateDosage()
            }
            
            if let dosage = dosage {
                Section(header: Text("结果")) {
                    Text("推荐剂量是 \(String(format: "%.2f", dosage)) mg")
                }
            }
        }
        .navigationTitle("药物剂量计算")
    }
    
    private func calculateDosage() {
        guard let weight = Double(weight), let concentration = Double(concentration), concentration > 0 else {
            return
        }
        
        switch dosageType {
        case "Ibuprofen Adult":
            dosage = weight * 10 / concentration
        case "Ibuprofen Child":
            guard let age = Double(age) else { return }
            dosage = age * 10 / concentration
        case "Theophylline Adult", "Theophylline Child":
            guard let bsa = Double(bsa) else { return }
            dosage = bsa * 10 / concentration
        default:
            dosage = nil
        }
    }
} 