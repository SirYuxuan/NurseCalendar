import SwiftUI
import UserNotifications

struct MedicationReminder: Identifiable, Codable {
    let id: String
    let medicationName: String
    let patientName: String
    let bedNumber: String
    let reminderTime: Date
    let dosage: String
    let notes: String
    let isEnabled: Bool
    let isRepeating: Bool
    var selectedDays: Set<Int>
    var isCompleted: Bool
    
    init(id: String = UUID().uuidString, 
         medicationName: String, 
         patientName: String,
         bedNumber: String,
         reminderTime: Date, 
         dosage: String, 
         notes: String, 
         isEnabled: Bool = true,
         isRepeating: Bool = false,
         selectedDays: Set<Int> = [],
         isCompleted: Bool = false) {
        self.id = id
        self.medicationName = medicationName
        self.patientName = patientName
        self.bedNumber = bedNumber
        self.reminderTime = reminderTime
        self.dosage = dosage
        self.notes = notes
        self.isEnabled = isEnabled
        self.isRepeating = isRepeating
        self.selectedDays = selectedDays
        self.isCompleted = isCompleted
    }
}

class MedicationReminderManager: ObservableObject {
    @Published var reminders: [MedicationReminder] = []
    private let key = "medicationReminders"
    
    init() {
        loadReminders()
    }
    
    func addReminder(_ reminder: MedicationReminder) {
        reminders.append(reminder)
        saveReminders()
        scheduleNotification(for: reminder)
    }
    
    func updateReminder(_ updatedReminder: MedicationReminder) {
        if let index = reminders.firstIndex(where: { $0.id == updatedReminder.id }) {
            reminders[index] = updatedReminder
            saveReminders()
            cancelNotification(for: updatedReminder)
            if !updatedReminder.isCompleted {
                scheduleNotification(for: updatedReminder)
            }
        }
    }
    
    func markAsCompleted(_ reminder: MedicationReminder) {
        let updatedReminder = MedicationReminder(
            id: reminder.id,
            medicationName: reminder.medicationName,
            patientName: reminder.patientName,
            bedNumber: reminder.bedNumber,
            reminderTime: reminder.reminderTime,
            dosage: reminder.dosage,
            notes: reminder.notes,
            isEnabled: reminder.isEnabled,
            isRepeating: reminder.isRepeating,
            selectedDays: reminder.selectedDays,
            isCompleted: true
        )
        updateReminder(updatedReminder)
    }
    
    func deleteReminder(_ reminder: MedicationReminder) {
        reminders.removeAll { $0.id == reminder.id }
        saveReminders()
        cancelNotification(for: reminder)
    }
    
    private func loadReminders() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([MedicationReminder].self, from: data) {
            reminders = decoded
            // 重新安排所有通知
            for reminder in reminders where reminder.isEnabled {
                scheduleNotification(for: reminder)
            }
        }
    }
    
    private func saveReminders() {
        if let encoded = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    private func scheduleNotification(for reminder: MedicationReminder) {
        let content = UNMutableNotificationContent()
        content.title = "服药提醒"
        content.body = "病人: \(reminder.patientName)\n床号: \(reminder.bedNumber)\n药物: \(reminder.medicationName)\n剂量: \(reminder.dosage)"
        content.sound = .default
        
        if reminder.isRepeating {
            // 为每个选中的星期几创建通知
            for weekday in reminder.selectedDays {
                var components = Calendar.current.dateComponents([.hour, .minute], from: reminder.reminderTime)
                components.weekday = weekday + 1 // 转换为日历组件的星期表示（1-7）
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                let request = UNNotificationRequest(
                    identifier: "\(reminder.id)_\(weekday)",
                    content: content,
                    trigger: trigger
                )
                UNUserNotificationCenter.current().add(request)
            }
        } else {
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.reminderTime)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: reminder.id, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    private func cancelNotification(for reminder: MedicationReminder) {
        if reminder.isRepeating {
            // 取消所有相关的通知
            let identifiers = (0..<7).map { "\(reminder.id)_\($0)" }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        } else {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder.id])
        }
    }
}

struct MedicationReminderView: View {
    @StateObject private var reminderManager = MedicationReminderManager()
    @State private var showingAddReminder = false
    @State private var selectedReminder: MedicationReminder?
    
    var body: some View {
        NavigationStack {
            List {
                if reminderManager.reminders.isEmpty {
                    Text("还没有添加任何用药提醒")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(reminderManager.reminders) { reminder in
                        ReminderRow(reminder: reminder)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedReminder = reminder
                            }
                            .swipeActions(edge: .trailing) {
                                if !reminder.isCompleted {
                                    Button {
                                        reminderManager.markAsCompleted(reminder)
                                    } label: {
                                        Label("完成", systemImage: "checkmark")
                                    }
                                    .tint(.green)
                                }
                                Button(role: .destructive) {
                                    reminderManager.deleteReminder(reminder)
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    selectedReminder = reminder
                                } label: {
                                    Label("编辑", systemImage: "pencil")
                                }
                                .tint(.orange)
                            }
                    }
                }
            }
            .navigationTitle("药物提醒")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddReminder = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddReminder) {
            AddReminderView(reminderManager: reminderManager)
        }
        .sheet(item: $selectedReminder) { reminder in
            AddReminderView(reminderManager: reminderManager, editingReminder: reminder)
        }
        .onAppear {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                if granted {
                    print("通知权限获取成功")
                }
            }
        }
    }
}

struct ReminderRow: View {
    let reminder: MedicationReminder
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "pills.fill")
                    .foregroundColor(reminder.isCompleted ? .gray : .green)
                VStack(alignment: .leading) {
                    Text(reminder.medicationName)
                        .font(.headline)
                    HStack {
                        Text(reminder.patientName)
                        Text("床号: \(reminder.bedNumber)")
                    }
                    .font(.subheadline)
                    .foregroundColor(.gray)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(formatTime(reminder.reminderTime))
                    Text(reminder.isRepeating ? "循环" : "单次")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            if !reminder.dosage.isEmpty {
                Text("剂量: \(reminder.dosage)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            if !reminder.notes.isEmpty {
                Text(reminder.notes)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
        .opacity(reminder.isCompleted ? 0.6 : 1)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(date) {
            formatter.dateFormat = "HH:mm"
        } else {
            formatter.dateFormat = "MM-dd HH:mm"
        }
        return formatter.string(from: date)
    }
}

struct WeekdayButton: View {
    let day: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Text(day)
            .font(.system(size: 14))
            .frame(height: 32)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(8)
            .padding(.horizontal, 2)
            .onTapGesture {
                action()
            }
    }
}

struct AddReminderView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.locale) var locale
    @ObservedObject var reminderManager: MedicationReminderManager
    
    let editingReminder: MedicationReminder?
    let weekdays = ["日", "一", "二", "三", "四", "五", "六"]
    
    init(reminderManager: MedicationReminderManager, editingReminder: MedicationReminder? = nil) {
        self.reminderManager = reminderManager
        self.editingReminder = editingReminder
        
        if let reminder = editingReminder {
            _medicationName = State(initialValue: reminder.medicationName)
            _patientName = State(initialValue: reminder.patientName)
            _bedNumber = State(initialValue: reminder.bedNumber)
            _reminderTime = State(initialValue: reminder.reminderTime)
            _dosage = State(initialValue: reminder.dosage)
            _notes = State(initialValue: reminder.notes)
            _isRepeating = State(initialValue: reminder.isRepeating)
            _selectedDays = State(initialValue: reminder.selectedDays)
        }
    }
    
    @State private var medicationName = ""
    @State private var patientName = ""
    @State private var bedNumber = ""
    @State private var reminderTime = Date()
    @State private var dosage = ""
    @State private var notes = ""
    @State private var isRepeating = false
    @State private var selectedDays: Set<Int> = []
    @State private var showingAlert = false
    
    let commonDosages = ["5mg", "10mg", "15mg", "20mg", "25mg", "50mg", "100mg"]
    @State private var showingDosagePicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("病人信息")) {
                    TextField("病人姓名", text: $patientName)
                    TextField("床号", text: $bedNumber)
                }
                
                Section(header: Text("药物信息")) {
                    TextField("药物名称", text: $medicationName)
                    TextField("剂量", text: $dosage)
                    TextField("备注", text: $notes)
                }
                
                Section(header: Text("提醒设置")) {
                    Toggle("循环提醒", isOn: $isRepeating)
                    
                    if isRepeating {
                        HStack(spacing: 0) {
                            ForEach(0..<7) { index in
                                WeekdayButton(
                                    day: weekdays[index],
                                    isSelected: selectedDays.contains(index)
                                ) {
                                    if selectedDays.contains(index) {
                                        selectedDays.remove(index)
                                    } else {
                                        selectedDays.insert(index)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    
                    DatePicker(
                        "时间",
                        selection: $reminderTime,
                        displayedComponents: isRepeating ? [.hourAndMinute] : [.date, .hourAndMinute]
                    )
                    .environment(\.locale, Locale(identifier: "zh_CN"))
                }
            }
            .navigationTitle(editingReminder == nil ? "添加提醒" : "编辑提醒")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        if !medicationName.isEmpty && !patientName.isEmpty {
                            if isRepeating && selectedDays.isEmpty {
                                showingAlert = true
                                return
                            }
                            
                            let reminder = MedicationReminder(
                                id: editingReminder?.id ?? UUID().uuidString,
                                medicationName: medicationName,
                                patientName: patientName,
                                bedNumber: bedNumber,
                                reminderTime: reminderTime,
                                dosage: dosage,
                                notes: notes,
                                isEnabled: true,
                                isRepeating: isRepeating,
                                selectedDays: selectedDays,
                                isCompleted: editingReminder?.isCompleted ?? false
                            )
                            if editingReminder != nil {
                                reminderManager.updateReminder(reminder)
                            } else {
                                reminderManager.addReminder(reminder)
                            }
                            dismiss()
                        } else {
                            showingAlert = true
                        }
                    }
                }
            }
            .alert("请输入必要信息", isPresented: $showingAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(isRepeating && selectedDays.isEmpty ? 
                     "请选择至少一天进行循环提醒" : 
                     "请输入药物名称和病人姓名")
            }
        }
    }
} 