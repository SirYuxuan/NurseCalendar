import SwiftUI

struct SettingsView: View {
    @AppStorage("startDate") private var startDateString: String = Date().ISO8601Format()
    @AppStorage("shiftPattern") private var shiftPatternData: Data = {
        try! JSONEncoder().encode(ShiftType.defaultPattern)
    }()
    
    @State private var startDate = Date()
    @State private var shiftPattern: [ShiftType] = []
    @State private var showingShiftPicker = false
    
    var body: some View {
        List {
            Section("排班设置") {
                DatePicker("开始日期", 
                          selection: $startDate,
                          displayedComponents: [.date])
                    .environment(\.locale, Locale(identifier: "zh_CN"))
                    .onChange(of: startDate) { oldValue, newValue in
                        startDateString = newValue.ISO8601Format()
                    }
            }
            
            Section {
                if shiftPattern.isEmpty {
                    Text("点击右上角 + 添加班次")
                        .foregroundColor(.gray)
                } else {
                    ForEach(shiftPattern, id: \.self) { shift in
                        HStack {
                            Circle()
                                .fill(shift.color)
                                .frame(width: 10, height: 10)
                            Text(shift.name)
                                .foregroundColor(shift.color)
                        }
                    }
                    .onMove { from, to in
                        shiftPattern.move(fromOffsets: from, toOffset: to)
                        if let data = try? JSONEncoder().encode(shiftPattern) {
                            shiftPatternData = data
                        }
                    }
                    .onDelete { indexSet in
                        shiftPattern.remove(atOffsets: indexSet)
                        if let data = try? JSONEncoder().encode(shiftPattern) {
                            shiftPatternData = data
                        }
                    }
                }
            } header: {
                Text("排班顺序")
            } footer: {
                Text("拖动调整顺序，左滑删除")
            }
        }
        .environment(\.locale, Locale(identifier: "zh_CN"))
        .navigationTitle("设置")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingShiftPicker = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
                    .environment(\.locale, Locale(identifier: "zh_CN"))
            }
        }
        .sheet(isPresented: $showingShiftPicker) {
            ShiftPickerView(shiftPattern: $shiftPattern)
        }
        .onChange(of: shiftPattern) { oldValue, newValue in
            if let data = try? JSONEncoder().encode(newValue) {
                shiftPatternData = data
            }
        }
        .onAppear {
            loadSavedData()
        }
    }
    
    private func loadSavedData() {
        if let date = ISO8601DateFormatter().date(from: startDateString) {
            startDate = date
        }
        if let pattern = try? JSONDecoder().decode([ShiftType].self, from: shiftPatternData) {
            shiftPattern = pattern
        } else {
            shiftPattern = ShiftType.defaultPattern
            if let data = try? JSONEncoder().encode(shiftPattern) {
                shiftPatternData = data
            }
        }
    }
} 
