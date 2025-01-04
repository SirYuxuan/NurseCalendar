import SwiftUI
import UserNotifications

struct MedicationReminderView: View {
    @State private var medicationName: String = ""
    @State private var reminderTime = Date()
    @State private var showingAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("药物信息")) {
                    TextField("药物名称", text: $medicationName)
                }
                
                Section(header: Text("提醒时间")) {
                    DatePicker("时间", selection: $reminderTime, displayedComponents: .hourAndMinute)
                }
                
                Button("设置提醒") {
                    scheduleMedicationReminder()
                }
            }
            .navigationTitle("药物提醒")
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("提醒已设置"), message: Text("药物提醒已成功设置"), dismissButton: .default(Text("确定")))
            }
        }
    }
    
    private func scheduleMedicationReminder() {
        let content = UNMutableNotificationContent()
        content.title = "药物提醒"
        content.body = "该服用 \(medicationName) 了"
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if error == nil {
                DispatchQueue.main.async {
                    showingAlert = true
                }
            }
        }
    }
} 