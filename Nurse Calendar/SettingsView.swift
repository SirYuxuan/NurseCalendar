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
                DatePicker("起始日期",
                          selection: $startDate,
                          displayedComponents: [.date])
                    .environment(\.locale, Locale(identifier: "zh_CN"))
                    .onChange(of: startDate) { oldValue, newValue in
                        startDateString = newValue.ISO8601Format()
                    }
            } footer: {
                Text("从这天开始按照下方顺序循环排班")
                    .font(.caption)
            }

            Section("排班设置") {
                Button {
                    showingTemplates = true
                } label: {
                    HStack {
                        Image(systemName: "square.grid.2x2.fill")
                            .foregroundColor(.purple)
                        Text("使用模板")
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
                        Text("添加班次")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Section {
                if shiftPattern.isEmpty {
                    VStack(spacing: 6) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 32))
                            .foregroundColor(.gray)
                        Text("请使用上方模板或添加班次")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                } else {
                    ForEach(Array(shiftPattern.enumerated()), id: \.offset) { index, shift in
                        HStack(spacing: 10) {
                            Circle()
                                .fill(shift.color)
                                .frame(width: 10, height: 10)

                            Text(shift.name)
                                .foregroundColor(shift.color)
                                .font(.subheadline)

                            Spacer()
                        }
                        .contentShape(Rectangle())
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
                    Text("循环顺序")
                    if !shiftPattern.isEmpty {
                        Text("(\(shiftPattern.count)天)")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    if !shiftPattern.isEmpty {
                        Button(editMode == .active ? "完成" : "编辑") {
                            editMode = editMode == .active ? .inactive : .active
                        }
                        .font(.caption)
                    }
                }
            } footer: {
                if !shiftPattern.isEmpty && editMode == .active {
                    Text("拖动调整顺序，左滑删除")
                        .font(.caption)
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
                ForEach(Array(ShiftTemplate.templates.enumerated()), id: \.offset) { index, template in
                    Button {
                        shiftPattern = template.pattern
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: template.icon)
                                .font(.title3)
                                .foregroundColor(.blue)
                                .frame(width: 32)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(template.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)

                                Text(template.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                HStack(spacing: 3) {
                                    ForEach(template.pattern, id: \.self) { shift in
                                        Circle()
                                            .fill(shift.color)
                                            .frame(width: 6, height: 6)
                                    }
                                }
                                .padding(.top, 2)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("选择模板")
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
