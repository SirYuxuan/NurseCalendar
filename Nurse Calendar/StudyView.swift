import SwiftUI

struct StudyView: View {
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("课程列表")) {
                    ForEach(0..<5) { index in
                        NavigationLink(destination: CourseDetailView(courseName: "课程 \(index + 1)")) {
                            HStack {
                                Image(systemName: "book.circle")
                                    .foregroundColor(.blue)
                                Text("课程 \(index + 1)")
                            }
                        }
                    }
                }
                
                Section(header: Text("学习进度")) {
                    ProgressView(value: 0.5)
                        .progressViewStyle(LinearProgressViewStyle(tint: .green))
                    Text("已完成 50%")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Section(header: Text("学习资源")) {
                    NavigationLink(destination: ResourceView()) {
                        HStack {
                            Image(systemName: "folder")
                                .foregroundColor(.orange)
                            Text("资源库")
                        }
                    }
                }
            }
            .navigationTitle("学习")
        }
    }
}

struct CourseDetailView: View {
    let courseName: String
    
    var body: some View {
        VStack {
            Text(courseName)
                .font(.largeTitle)
                .padding()
            Text("课程详细内容将在这里显示。")
                .font(.body)
                .padding()
            Spacer()
        }
        .navigationTitle(courseName)
    }
}

struct ResourceView: View {
    var body: some View {
        VStack {
            Text("资源库")
                .font(.largeTitle)
                .padding()
            Text("这里是学习资源的详细信息。")
                .font(.body)
                .padding()
            Spacer()
        }
        .navigationTitle("资源库")
    }
} 