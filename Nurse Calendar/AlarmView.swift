import SwiftUI
import UserNotifications

struct AlarmItem: Identifiable, Codable {
    let id: String
    let title: String
    let fireDate: Date
    let type: AlarmType

    enum AlarmType: String, Codable {
        case skinTest = "皮试"
        case custom = "自定义"
    }
}

class AlarmManager: ObservableObject {
    @Published var alarms: [AlarmItem] = []

    init() {
        loadAlarms()
    }

    func addAlarm(_ alarm: AlarmItem) {
        alarms.append(alarm)
        alarms.sort { $0.fireDate < $1.fireDate }
        saveAlarms()
    }

    func removeAlarm(_ alarm: AlarmItem) {
        alarms.removeAll { $0.id == alarm.id }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [alarm.id])
        saveAlarms()
    }

    func loadAlarms() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                let now = Date()
                // 只保留未过期的闹钟
                self.alarms = requests.compactMap { request in
                    guard let trigger = request.trigger as? UNTimeIntervalNotificationTrigger,
                          let fireDate = trigger.nextTriggerDate() else {
                        return nil
                    }

                    // 跳过已过期的闹钟(5秒容差)
                    if fireDate.addingTimeInterval(5) < now {
                        return nil
                    }

                    let type: AlarmItem.AlarmType = request.content.title == "皮试提醒" ? .skinTest : .custom

                    return AlarmItem(
                        id: request.identifier,
                        title: request.content.title,
                        fireDate: fireDate,
                        type: type
                    )
                }.sorted { $0.fireDate < $1.fireDate }

                // 清理已过期的通知
                self.removeExpiredAlarms()
            }
        }
    }

    private func removeExpiredAlarms() {
        let now = Date()
        let expiredIDs = alarms.filter { $0.fireDate.addingTimeInterval(5) < now }.map { $0.id }

        if !expiredIDs.isEmpty {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: expiredIDs)
            alarms.removeAll { expiredIDs.contains($0.id) }
        }
    }

    private func saveAlarms() {
        // 闹钟数据已保存在系统通知中心，这里只是触发UI更新
    }
}

struct AlarmView: View {
    @StateObject private var alarmManager = AlarmManager()
    @State private var selectedMinutes: Int = 15
    @State private var selectedSound: AlarmSound = .default
    @State private var isVibrationEnabled: Bool = true
    @State private var notificationPermissionGranted: Bool = false
    @State private var showingPermissionAlert: Bool = false
    @State private var showingSuccessAlert: Bool = false

    private let minuteOptions = [1, 5, 10, 15, 20, 30]
    private let cleanupTimer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            Form {
                Section("快速设置") {
                    Button {
                        addSkinTestAlarm()
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.red.opacity(0.15))
                                    .frame(width: 44, height: 44)

                                Image(systemName: "alarm.fill")
                                    .font(.title3)
                                    .foregroundColor(.red)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("一键添加皮试闹钟")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)

                                Text("\(selectedMinutes) 分钟后提醒")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.red)
                                .font(.title2)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }

                Section("闹钟设置") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("提醒时间")
                                .font(.subheadline)
                            Spacer()
                        }

                        HStack(spacing: 8) {
                            ForEach(minuteOptions, id: \.self) { minutes in
                                Button {
                                    selectedMinutes = minutes
                                } label: {
                                    Text("\(minutes)分钟")
                                        .font(.caption)
                                        .fontWeight(selectedMinutes == minutes ? .semibold : .regular)
                                        .foregroundColor(selectedMinutes == minutes ? .white : .primary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(selectedMinutes == minutes ? Color.red : Color.red.opacity(0.1))
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.vertical, 4)

                    Picker("铃声", selection: $selectedSound) {
                        ForEach(AlarmSound.allCases, id: \.self) { sound in
                            HStack {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.caption)
                                Text(sound.displayName)
                            }
                            .tag(sound)
                        }
                    }

                    Toggle(isOn: $isVibrationEnabled) {
                        HStack(spacing: 8) {
                            Image(systemName: "iphone.radiowaves.left.and.right")
                                .font(.caption)
                            Text("震动")
                        }
                    }
                    .tint(.red)
                }

                if !alarmManager.alarms.isEmpty {
                    Section("待触发闹钟") {
                        ForEach(alarmManager.alarms) { alarm in
                            AlarmRow(alarm: alarm) {
                                alarmManager.removeAlarm(alarm)
                            }
                        }
                    }
                }

                if !notificationPermissionGranted {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                    .font(.caption)
                                Text("需要通知权限")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }

                            Text("请在设置中允许通知权限，以便正常使用闹钟功能")
                                .font(.caption2)
                                .foregroundColor(.secondary)

                            Button {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                Text("前往设置")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Section {
                    HStack(spacing: 4) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text("皮试通常需要在注射后 15-20 分钟观察反应")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("闹钟")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                checkNotificationPermission()
                alarmManager.loadAlarms()
            }
            .onReceive(cleanupTimer) { _ in
                alarmManager.loadAlarms()
            }
            .alert("权限请求", isPresented: $showingPermissionAlert) {
                Button("取消", role: .cancel) { }
                Button("去设置") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text("需要通知权限才能设置闹钟。请在设置中开启通知权限。")
            }
            .alert("闹钟已设置", isPresented: $showingSuccessAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text("已成功添加皮试闹钟")
            }
        }
    }

    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationPermissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }

    private func addSkinTestAlarm() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .authorized {
                    scheduleNotification()
                } else if settings.authorizationStatus == .notDetermined {
                    requestNotificationPermission()
                } else {
                    showingPermissionAlert = true
                }
            }
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                notificationPermissionGranted = granted
                if granted {
                    scheduleNotification()
                } else {
                    showingPermissionAlert = true
                }
            }
        }
    }

    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "皮试提醒"
        content.body = "请查看患者皮试结果"
        content.sound = selectedSound.notificationSound
        // 不设置角标

        // 设置为时间敏感,确保能够突破勿扰模式
        if isVibrationEnabled {
            content.interruptionLevel = .timeSensitive
        } else {
            content.interruptionLevel = .active
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(selectedMinutes * 60), repeats: false)

        let identifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ 闹钟设置失败: \(error.localizedDescription)")
                } else {
                    print("✅ 闹钟设置成功: \(self.selectedMinutes)分钟后")
                    let alarm = AlarmItem(
                        id: identifier,
                        title: "皮试提醒",
                        fireDate: Date().addingTimeInterval(TimeInterval(self.selectedMinutes * 60)),
                        type: .skinTest
                    )
                    self.alarmManager.addAlarm(alarm)
                    self.showingSuccessAlert = true
                }
            }
        }
    }
}

struct AlarmRow: View {
    let alarm: AlarmItem
    let onDelete: () -> Void

    private var fireTimeString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: alarm.fireDate)
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.red.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: "alarm.fill")
                    .font(.body)
                    .foregroundColor(.red)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(alarm.title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(fireTimeString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button {
                onDelete()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .font(.title3)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 2)
    }
}

enum AlarmSound: String, CaseIterable {
    case `default` = "default"
    case chime = "chime"
    case bell = "bell"
    case aurora = "aurora"
    case bamboo = "bamboo"

    var displayName: String {
        switch self {
        case .default: return "默认"
        case .chime: return "风铃"
        case .bell: return "铃铛"
        case .aurora: return "极光"
        case .bamboo: return "竹子"
        }
    }

    var notificationSound: UNNotificationSound {
        switch self {
        case .default:
            return .default
        default:
            // 系统内置铃声
            return UNNotificationSound(named: UNNotificationSoundName(rawValue: "\(rawValue).caf"))
        }
    }
}
