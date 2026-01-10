import SwiftUI
import AVFoundation
import UserNotifications
import AudioToolbox

// 闹钟播放器 - 负责持续播放铃声
class AlarmPlayer: ObservableObject {
    static let shared = AlarmPlayer()

    @Published var isRinging = false
    @Published var currentAlarm: AlarmItem?

    private var audioPlayer: AVAudioPlayer?
    private var checkTimer: Timer?
    private var soundTimer: Timer?

    private init() {
        setupAudioSession()
        startMonitoring()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ 音频会话设置失败: \(error)")
        }
    }

    func startMonitoring() {
        // 每秒检查一次是否有闹钟到时间
        checkTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkAlarms()
        }
    }

    private func checkAlarms() {
        guard !isRinging else { return }

        UNUserNotificationCenter.current().getPendingNotificationRequests { [weak self] requests in
            guard let self = self else { return }
            let now = Date()

            for request in requests {
                guard let trigger = request.trigger as? UNTimeIntervalNotificationTrigger,
                      let fireDate = trigger.nextTriggerDate() else {
                    continue
                }

                // 检查是否有闹钟到时间或在过去10秒内触发
                let timeDiff = now.timeIntervalSince(fireDate)

                if timeDiff >= -1 && timeDiff <= 10 {
                    let alarm = AlarmItem(
                        id: request.identifier,
                        title: request.content.title,
                        fireDate: fireDate,
                        type: request.content.title == "皮试提醒" ? .skinTest : .custom
                    )

                    DispatchQueue.main.async {
                        print("⏰ 触发闹钟: \(alarm.title), 时间差: \(String(format: "%.1f", timeDiff))秒")
                        self.triggerAlarm(alarm)
                    }
                    break
                }
            }
        }
    }

    func triggerAlarm(_ alarm: AlarmItem) {
        guard !isRinging else {
            print("⚠️ 已有闹钟在响，忽略新闹钟")
            return
        }

        print("✅ 开始触发闹钟")
        currentAlarm = alarm
        isRinging = true
        playAlarmSound()
    }

    private func playAlarmSound() {
        print("🔔 开始播放系统提示音")

        // 使用系统振动和提示音（每2秒一次）
        soundTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            // 播放系统默认提示音（1007 是系统警告音）
            AudioServicesPlaySystemSound(1007)
            // 触发振动
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            print("🔔 播放提示音和振动")
        }

        // 立即播放一次
        AudioServicesPlaySystemSound(1007)
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }

    func stopAlarm() {
        print("🛑 停止闹钟")
        soundTimer?.invalidate()
        soundTimer = nil
        audioPlayer?.stop()
        audioPlayer = nil
        isRinging = false

        // 从通知中心移除这个闹钟
        if let alarmId = currentAlarm?.id {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [alarmId])
            print("🗑️ 已移除闹钟通知: \(alarmId)")
        }

        currentAlarm = nil
    }

    deinit {
        checkTimer?.invalidate()
        soundTimer?.invalidate()
    }
}

// 全屏闹钟响铃界面
struct AlarmRingingView: View {
    let alarm: AlarmItem
    let onDismiss: () -> Void

    @State private var pulseAnimation = false

    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                colors: [Color.red.opacity(0.8), Color.orange.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // 闹钟图标 - 带脉冲动画
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 200, height: 200)
                        .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                        .opacity(pulseAnimation ? 0 : 0.5)

                    Image(systemName: "alarm.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                        pulseAnimation = true
                    }
                }

                // 标题
                VStack(spacing: 12) {
                    Text(alarm.title)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)

                    Text(getCurrentTime())
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }

                Spacer()

                // 关闭按钮
                Button {
                    onDismiss()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                        Text("关闭闹钟")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }

    private func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }
}
