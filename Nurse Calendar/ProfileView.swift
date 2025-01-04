import SwiftUI

struct ProfileView: View {
    @State private var username: String = "用户名"
    @State private var email: String = "user@example.com"
    @State private var showingEditProfile = false
    @State private var showingFeedback = false

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("个人信息")) {
                    HStack {
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text(username)
                                .font(.headline)
                            Text(email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    Button("编辑个人信息") {
                        showingEditProfile = true
                    }
                }
                
                Section(header: Text("设置")) {
                    NavigationLink(destination: NotificationSettingsView()) {
                        HStack {
                            Image(systemName: "bell")
                                .foregroundColor(.orange)
                            Text("通知设置")
                        }
                    }
                    
                    NavigationLink(destination: PrivacySettingsView()) {
                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(.red)
                            Text("隐私设置")
                        }
                    }
                }
                
                Section(header: Text("支持")) {
                    Button("反馈") {
                        showingFeedback = true
                    }
                    NavigationLink(destination: SupportView()) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.purple)
                            Text("帮助与支持")
                        }
                    }
                }
                
                Section(header: Text("关于")) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.green)
                        Text("版本 1.0.0")
                    }
                }
            }
            .navigationTitle("我的")
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(username: $username, email: $email)
            }
            .sheet(isPresented: $showingFeedback) {
                FeedbackView()
            }
        }
    }
}

struct EditProfileView: View {
    @Binding var username: String
    @Binding var email: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("编辑信息")) {
                    TextField("用户名", text: $username)
                    TextField("电子邮件", text: $email)
                }
            }
            .navigationTitle("编辑个人信息")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct NotificationSettingsView: View {
    var body: some View {
        Text("通知设置")
            .font(.largeTitle)
            .padding()
    }
}

struct PrivacySettingsView: View {
    var body: some View {
        Text("隐私设置")
            .font(.largeTitle)
            .padding()
    }
}

struct SupportView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("帮助与支持")
                .font(.largeTitle)
                .padding(.top)
            
            Text("常见问题")
                .font(.headline)
            Text("1. 如何使用应用？\n2. 如何更改设置？\n3. 如何联系支持？")
                .font(.body)
                .padding(.bottom)
            
            Text("联系我们")
                .font(.headline)
            Text("如果您有任何问题或需要帮助，请通过以下方式联系我们：\nEmail: support@example.com\n电话: 123-456-7890")
                .font(.body)
            
            Spacer()
        }
        .padding()
        .navigationTitle("帮助与支持")
    }
}

struct FeedbackView: View {
    @Environment(\.dismiss) var dismiss
    @State private var feedbackText: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("反馈")) {
                    TextEditor(text: $feedbackText)
                        .frame(height: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                }
            }
            .navigationTitle("反馈")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("提交") {
                        // 提交反馈逻辑
                        dismiss()
                    }
                }
            }
        }
    }
} 