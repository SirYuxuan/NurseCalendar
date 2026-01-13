import SwiftUI

struct MedicalAbbreviation: Identifiable {
    let id = UUID()
    let abbreviation: String
    let fullName: String
    let category: String
}

struct MedicalAbbreviationView: View {
    @State private var searchText = ""
    @State private var selectedCategory: String = "全部"

    private let categories = ["全部", "给药时间", "给药频次", "护理缩写"]

    private let abbreviations: [MedicalAbbreviation] = [
        // 给药时间
        MedicalAbbreviation(abbreviation: "prn", fullName: "需要时<长期>", category: "给药时间"),
        MedicalAbbreviation(abbreviation: "sos", fullName: "需要时<限用一次,12h内有效>", category: "给药时间"),
        MedicalAbbreviation(abbreviation: "ac", fullName: "饭前", category: "给药时间"),
        MedicalAbbreviation(abbreviation: "pc", fullName: "饭后", category: "给药时间"),
        MedicalAbbreviation(abbreviation: "DC", fullName: "停止、取消", category: "给药时间"),
        MedicalAbbreviation(abbreviation: "12n", fullName: "中午12点", category: "给药时间"),
        MedicalAbbreviation(abbreviation: "hs", fullName: "临睡前", category: "给药时间"),
        MedicalAbbreviation(abbreviation: "am", fullName: "上午", category: "给药时间"),
        MedicalAbbreviation(abbreviation: "pm", fullName: "下午", category: "给药时间"),
        MedicalAbbreviation(abbreviation: "st", fullName: "立即", category: "给药时间"),
        MedicalAbbreviation(abbreviation: "12mn", fullName: "午夜12点", category: "给药时间"),

        // 给药频次
        MedicalAbbreviation(abbreviation: "qd", fullName: "每日一次", category: "给药频次"),
        MedicalAbbreviation(abbreviation: "bid", fullName: "每日两次", category: "给药频次"),
        MedicalAbbreviation(abbreviation: "tid", fullName: "每日三次", category: "给药频次"),
        MedicalAbbreviation(abbreviation: "qid", fullName: "每日四次", category: "给药频次"),
        MedicalAbbreviation(abbreviation: "biw", fullName: "每周两次", category: "给药频次"),
        MedicalAbbreviation(abbreviation: "qh", fullName: "每小时一次", category: "给药频次"),
        MedicalAbbreviation(abbreviation: "qxh", fullName: "每x小时一次", category: "给药频次"),
        MedicalAbbreviation(abbreviation: "qn", fullName: "每晚一次", category: "给药频次"),
        MedicalAbbreviation(abbreviation: "qod", fullName: "隔日一次", category: "给药频次"),

        // 护理常用缩写
        MedicalAbbreviation(abbreviation: "po", fullName: "口服", category: "护理缩写"),
        MedicalAbbreviation(abbreviation: "pr", fullName: "灌肠", category: "护理缩写"),
        MedicalAbbreviation(abbreviation: "iv", fullName: "静脉注射", category: "护理缩写"),
        MedicalAbbreviation(abbreviation: "im", fullName: "肌内注射", category: "护理缩写"),
        MedicalAbbreviation(abbreviation: "ih", fullName: "皮下注射", category: "护理缩写"),
        MedicalAbbreviation(abbreviation: "ic", fullName: "皮内注射", category: "护理缩写"),
        MedicalAbbreviation(abbreviation: "ip", fullName: "腹腔注射", category: "护理缩写"),
        MedicalAbbreviation(abbreviation: "ct", fullName: "皮试", category: "护理缩写"),
        MedicalAbbreviation(abbreviation: "ivgtt", fullName: "静脉滴注", category: "护理缩写"),
        MedicalAbbreviation(abbreviation: "qs", fullName: "足够量", category: "护理缩写"),
        MedicalAbbreviation(abbreviation: "GS", fullName: "葡萄糖", category: "护理缩写"),
        MedicalAbbreviation(abbreviation: "GNs", fullName: "葡萄糖氯化钠", category: "护理缩写"),
        MedicalAbbreviation(abbreviation: "NaCL", fullName: "氯化钠", category: "护理缩写"),
        MedicalAbbreviation(abbreviation: "KCL", fullName: "氯化钾", category: "护理缩写"),
        MedicalAbbreviation(abbreviation: "NS", fullName: "生理盐水=0.9%NaCL或NS", category: "护理缩写"),
        MedicalAbbreviation(abbreviation: "PG", fullName: "青霉素", category: "护理缩写"),
        MedicalAbbreviation(abbreviation: "Vit", fullName: "维生素", category: "护理缩写"),
        MedicalAbbreviation(abbreviation: "DXN", fullName: "地塞米松", category: "护理缩写"),
        MedicalAbbreviation(abbreviation: "RI", fullName: "胰岛素", category: "护理缩写"),
        MedicalAbbreviation(abbreviation: "复方氯化钠", fullName: "复方氯化钠=林格氏液", category: "护理缩写"),
        MedicalAbbreviation(abbreviation: "乳酸钠林格液", fullName: "乳酸钠林格液=平衡液", category: "护理缩写"),
    ]

    private var filteredAbbreviations: [MedicalAbbreviation] {
        var result = abbreviations

        if selectedCategory != "全部" {
            result = result.filter { $0.category == selectedCategory }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.abbreviation.localizedCaseInsensitiveContains(searchText) ||
                $0.fullName.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }

    private var groupedAbbreviations: [(String, [MedicalAbbreviation])] {
        let grouped = Dictionary(grouping: filteredAbbreviations, by: { $0.category })
        let order = ["给药时间", "给药频次", "护理缩写"]
        return order.compactMap { category in
            if let items = grouped[category] {
                return (category, items)
            }
            return nil
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // 搜索栏
            HStack(spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .font(.system(size: 12))
                    TextField("搜索", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.subheadline)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .cornerRadius(8)

                if !searchText.isEmpty {
                    Button("取消") {
                        searchText = ""
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.top, 6)
            .padding(.bottom, 6)

            // 分类选择
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(categories, id: \.self) { category in
                        Button {
                            withAnimation {
                                selectedCategory = category
                            }
                        } label: {
                            Text(category)
                                .font(.system(size: 11))
                                .fontWeight(selectedCategory == category ? .semibold : .regular)
                                .foregroundColor(selectedCategory == category ? .white : .primary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedCategory == category ? Color.blue : Color(.systemGray5))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 6)

            // 列表
            ScrollView {
                VStack(spacing: 0) {
                    if selectedCategory == "全部" && searchText.isEmpty {
                        ForEach(groupedAbbreviations, id: \.0) { category, items in
                            VStack(alignment: .leading, spacing: 0) {
                                // 分类标题
                                Text(category)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 16)
                                    .padding(.top, 16)
                                    .padding(.bottom, 8)

                                // 网格布局
                                AbbreviationGrid(items: items)
                            }
                        }
                    } else {
                        AbbreviationGrid(items: filteredAbbreviations)
                            .padding(.top, 8)
                    }

                    // 参考资料
                    VStack(alignment: .leading, spacing: 8) {
                        Text("参考资料")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)

                        Text("医嘱缩写来源于临床护理标准用语和医学教材：")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        VStack(alignment: .leading, spacing: 4) {
                            Link("• 中华人民共和国药典", destination: URL(string: "http://www.nhc.gov.cn/")!)
                                .font(.caption)

                            Link("• 临床护理实践指南", destination: URL(string: "http://www.nhc.gov.cn/")!)
                                .font(.caption)

                            Text("• 《基础护理学》护理专业教材")
                                .font(.caption)
                                .foregroundColor(.primary)
                        }

                        Text("注：医嘱缩写仅供学习参考，实际使用以所在医疗机构规范为准。")
                            .font(.caption2)
                            .foregroundColor(.orange)
                            .padding(.top, 4)
                    }
                    .padding(16)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    .padding(.bottom, 16)
                }
            }
        }
        .navigationTitle("医嘱缩写")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// 网格布局组件
struct AbbreviationGrid: View {
    let items: [MedicalAbbreviation]

    // 将项目分组：长文本单独一行，短文本两个一行
    private var rows: [[MedicalAbbreviation]] {
        var result: [[MedicalAbbreviation]] = []
        var i = 0

        while i < items.count {
            let item = items[i]
            let isLong = item.fullName.count > 15

            if isLong {
                // 长文本：单独一行
                result.append([item])
                i += 1
            } else {
                // 短文本：尝试和下一个配对
                let hasNext = i + 1 < items.count
                if hasNext {
                    let nextItem = items[i + 1]
                    let nextIsLong = nextItem.fullName.count > 15

                    if nextIsLong {
                        // 下一个是长文本，当前短文本单独一行
                        result.append([item])
                        i += 1
                    } else {
                        // 两个短文本一行
                        result.append([item, nextItem])
                        i += 2
                    }
                } else {
                    // 最后一个短文本
                    result.append([item])
                    i += 1
                }
            }
        }

        return result
    }

    var body: some View {
        VStack(spacing: 8) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                if row.count == 1 {
                    // 单个项目
                    AbbreviationCard(abbreviation: row[0])
                        .padding(.horizontal, 16)
                } else {
                    // 两个项目
                    HStack(spacing: 8) {
                        AbbreviationCard(abbreviation: row[0])
                        AbbreviationCard(abbreviation: row[1])
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }
}

// 单个缩写卡片
struct AbbreviationCard: View {
    let abbreviation: MedicalAbbreviation

    var body: some View {
        HStack(spacing: 8) {
            Text(abbreviation.abbreviation)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.red)
                .frame(minWidth: 60, alignment: .leading)

            Text(abbreviation.fullName)
                .font(.system(size: 12))
                .foregroundColor(.primary)
                .lineLimit(2)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
    }
}
