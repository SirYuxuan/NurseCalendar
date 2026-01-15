import Foundation
import UIKit

struct UpdateChecker {
    private static let appStoreID = "6739861537"

    // 检查更新
    static func checkForUpdate() async {
        do {
            let needsUpdate = try await checkVersion()
            if needsUpdate {
                await MainActor.run {
                    showUpdateAlert()
                }
            }
        } catch {
            // 网络错误或其他错误，静默失败，不影响用户使用
            print("更新检查失败（可能无网络）: \(error.localizedDescription)")
        }
    }

    // 检查 App Store 版本
    private static func checkVersion() async throws -> Bool {
        let urlString = "https://itunes.apple.com/cn/lookup?id=\(appStoreID)"
        guard let url = URL(string: urlString) else {
            throw UpdateError.invalidURL
        }

        // 设置超时时间，避免长时间等待
        var request = URLRequest(url: url)
        request.timeoutInterval = 10

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw UpdateError.invalidResponse
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let results = json["results"] as? [[String: Any]],
              let firstResult = results.first,
              let storeVersion = firstResult["version"] as? String else {
            throw UpdateError.parseError
        }

        // 获取当前版本
        guard let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            throw UpdateError.currentVersionNotFound
        }

        print("📱 当前版本: \(currentVersion), App Store 版本: \(storeVersion)")

        // 比较版本号：只有当 App Store 版本大于当前版本时才提示更新
        let comparisonResult = storeVersion.compare(currentVersion, options: .numeric)
        return comparisonResult == .orderedDescending
    }

    // 显示更新弹窗（强制更新，无取消按钮）
    private static func showUpdateAlert() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }

        let alert = UIAlertController(
            title: "发现新版本",
            message: "为了给您提供更好的体验和功能，请立即更新到最新版本。",
            preferredStyle: .alert
        )

        // 只有"立即更新"按钮，强制更新
        alert.addAction(UIAlertAction(title: "立即更新", style: .default) { _ in
            openAppStore()
        })

        // 找到最顶层的 ViewController 来显示弹窗
        var topController = rootViewController
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }

        topController.present(alert, animated: true)
    }

    // 跳转到 App Store
    private static func openAppStore() {
        let urlString = "https://apps.apple.com/app/id\(appStoreID)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

// 错误类型
enum UpdateError: Error {
    case invalidURL
    case invalidResponse
    case parseError
    case currentVersionNotFound
}
