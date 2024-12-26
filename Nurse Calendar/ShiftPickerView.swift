import SwiftUI

struct ShiftPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var shiftPattern: [ShiftType]
    @AppStorage("shiftPattern") private var shiftPatternData: Data = try! JSONEncoder().encode(ShiftType.defaultPattern)
    @State private var customShiftName = ""
    @State private var showingCustomInput = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(ShiftType.predefinedCases, id: \.self) { shift in
                        ShiftRow(shift: shift) {
                            addShift(shift)
                        }
                    }
                } header: {
                    Text("预设班次")
                }
                
                Section {
                    Button {
                        showingCustomInput = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                            Text("添加自定义班次")
                                .foregroundColor(.primary)
                        }
                    }
                } header: {
                    Text("自定义班次")
                }
            }
            .navigationTitle("选择班次")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
            .alert("添加自定义班次", isPresented: $showingCustomInput) {
                TextField("班次名称", text: $customShiftName)
                Button("取消", role: .cancel) {
                    customShiftName = ""
                }
                Button("添加") {
                    if !customShiftName.isEmpty {
                        addShift(.custom(customShiftName))
                        customShiftName = ""
                    }
                }
            } message: {
                Text("请输入自定义班次的名称")
            }
        }
    }
    
    private func addShift(_ shift: ShiftType) {
        withAnimation {
            shiftPattern.append(shift)
            if let data = try? JSONEncoder().encode(shiftPattern) {
                shiftPatternData = data
            }
        }
        dismiss()
    }
}

struct ShiftRow: View {
    let shift: ShiftType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Circle()
                    .fill(shift.color)
                    .frame(width: 10, height: 10)
                Text(shift.name)
                    .foregroundColor(shift.color)
                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
} 