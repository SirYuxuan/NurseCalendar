import SwiftUI

struct ShiftTemplate {
    let name: String
    let description: String
    let pattern: [ShiftType]
    let icon: String

    static let templates = [
        ShiftTemplate(
            name: "四班三倒",
            description: "白班→夜班→下夜→休息",
            pattern: [.day, .night, .afterNight, .rest],
            icon: "calendar.badge.clock"
        ),
        ShiftTemplate(
            name: "五班三倒",
            description: "白班→白班→夜班→夜班→休息",
            pattern: [.day, .day, .night, .night, .rest],
            icon: "calendar.circle"
        ),
        ShiftTemplate(
            name: "两班倒",
            description: "白班→夜班→白班→夜班",
            pattern: [.day, .night, .day, .night],
            icon: "arrow.triangle.2.circlepath"
        ),
        ShiftTemplate(
            name: "连续夜班",
            description: "夜班→夜班→夜班→休息",
            pattern: [.night, .night, .night, .rest],
            icon: "moon.stars.fill"
        )
    ]
}

struct SettingsView: View {
    @AppStorage("startDate") private var startDateString: String = Date().ISO8601Format()
    @AppStorage("shiftPattern") private var shiftPatternData: Data = {
        try! JSONEncoder().encode(ShiftType.defaultPattern)
    }()

    @State private var startDate = Date()
    @State private var shiftPattern: [ShiftType] = []
    @State private var showingShiftPicker = false
    @State private var showingTemplates = false
    @State private var editMode: EditMode = .inactive

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        Text("设置说明")
                            .font(.headline)
                    }

                    Text("1. 选择您的第一个班次日期")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("2. 设置您的排班循环顺序")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("3. 系统将自动计算后续排班")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }

            Section {
                DatePicker("第一个班次日期",
                          selection: $startDate,
                          displayedComponents: [.date])
                    .environment(\.locale, Locale(identifier: "zh_CN"))
                    .onChange(of: startDate) { oldValue, newValue in
                        startDateString = newValue.ISO8601Format()
                    }

                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.orange)
                    Text("从这天开始按照下方顺序循环排班")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("起始日期")
            }

            Section {
                Button {
                    showingTemplates = true
                } label: {
                    HStack {
                        Image(systemName: "square.grid.2x2.fill")
                            .foregroundColor(.purple)
                        Text("使用排班模板")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Button {
                    showingShiftPicker = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                        Text("添加单个班次")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Text("快速设置")
            }

            Section {
                if shiftPattern.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("还没有设置排班顺序")
                            .foregroundColor(.gray)
                        Text("请使用上方模板或手动添加")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                } else {
                    ForEach(Array(shiftPattern.enumerated()), id: \.offset) { index, shift in
                        HStack(spacing: 12) {
                            Text("\(index + 1)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 24)

                            Circle()
                                .fill(shift.color)
                                .frame(width: 12, height: 12)

                            Text(shift.name)
                                .foregroundColor(shift.color)
                                .fontWeight(.medium)

                            Spacer()

                            if editMode == .active {
                                Image(systemName: "line.3.horizontal")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onMove { from, to in
                        shiftPattern.move(fromOffsets: from, toOffset: to)
                        savePattern()
                    }
                    .onDelete { indexSet in
                        shiftPattern.remove(atOffsets: indexSet)
                        savePattern()
                    }
                }
            } header: {
                HStack {
                    Text("排班循环顺序")
                    Spacer()
                    if !shiftPattern.isEmpty {
                        Button(editMode == .active ? "完成" : "编辑") {
                            withAnimation {
                                editMode = editMode == .active ? .inactive : .active
                            }
                        }
                        .font(.caption)
                    }
                }
            } footer: {
                if !shiftPattern.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("循环周期：\(shiftPattern.count) 天")
                            .font(.caption)
                        Text(editMode == .active ? "拖动调整顺序，左滑删除" : "点击右上角「编辑」可调整顺序")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            if !shiftPattern.isEmpty {
                Section {
                    ShiftPreviewView(
                        startDate: startDate,
                        pattern: shiftPattern
                    )
                } header: {
                    Text("排班预览")
                }
            }
        }
        .environment(\.editMode, $editMode)
        .environment(\.locale, Locale(identifier: "zh_CN"))
        .navigationTitle("排班设置")
        .sheet(isPresented: $showingShiftPicker) {
            ShiftPickerView(shiftPattern: $shiftPattern)
        }
        .sheet(isPresented: $showingTemplates) {
            ShiftTemplatePickerView(shiftPattern: $shiftPattern)
        }
        .onChange(of: shiftPattern) { oldValue, newValue in
            savePattern()
        }
        .onAppear {
            loadSavedData()
        }
    }

    private func savePattern() {
        if let data = try? JSONEncoder().encode(shiftPattern) {
            shiftPatternData = data
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
            savePattern()
        }
    }
}

struct ShiftPreviewView: View {
    let startDate: Date
    let pattern: [ShiftType]

    private var previewDates: [(Date, ShiftType)] {
        let calendar = Calendar.current
        var dates: [(Date, ShiftType)] = []

        for i in 0..<min(pattern.count, 7) {
            if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                dates.append((date, pattern[i % pattern.count]))
            }
        }

        return dates
    }

    var body: some View {
        VStack(spacing: 8) {
            ForEach(Array(previewDates.enumerated()), id: \.offset) { index, item in
                HStack {
                    Text(formatDate(item.0))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(width: 100, alignment: .leading)

                    Circle()
                        .fill(item.1.color)
                        .frame(width: 10, height: 10)

                    Text(item.1.name)
                        .foregroundColor(item.1.color)
                        .fontWeight(.medium)

                    Spacer()

                    if index == 0 {
                        Text("起始")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }
                }
                .padding(.vertical, 4)
            }

            if pattern.count > 7 {
                Text("... 继续循环")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "MM月dd日 E"
        return formatter.string(from: date)
    }
}

struct ShiftTemplatePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var shiftPattern: [ShiftType]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("选择一个常用的排班模板，快速完成设置")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .listRowBackground(Color.clear)
                }

                Section("常用模板") {
                    ForEach(Array(ShiftTemplate.templates.enumerated()), id: \.offset) { index, template in
                        Button {
                            withAnimation {
                                shiftPattern = template.pattern
                            }
                            dismiss()
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: template.icon)
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                    .frame(width: 40)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(template.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    Text(template.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    HStack(spacing: 4) {
                                        ForEach(template.pattern, id: \.self) { shift in
                                            Circle()
                                                .fill(shift.color)
                                                .frame(width: 8, height: 8)
                                        }
                                    }
                                    .padding(.top, 4)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .navigationTitle("选择排班模板")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
} 
