import SwiftUI

struct AthleteDetailView: View {
    @EnvironmentObject private var store: DiaryStore

    let status: AthleteDailyStatus

    @State private var coachName = "田中コーチ"
    @State private var commentText = ""

    var body: some View {
        List {
            Section("選手情報") {
                LabeledContent("氏名", value: status.athlete.name)
                LabeledContent("所属", value: status.athlete.company)
                LabeledContent("種目", value: status.athlete.event)
                HStack {
                    Text("注意判定")
                    Spacer()
                    AlertBadgeView(level: status.alertLevel)
                }
                Text(status.alertReasons.joined(separator: " / "))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section("朝チェックイン") {
                if let morning = status.record?.morningCheckIn {
                    LabeledContent("睡眠", value: String(format: "%.1f 時間", morning.sleepHours))
                    LabeledContent("睡眠の質", value: "\(morning.sleepQuality)/5")
                    LabeledContent("疲労感", value: "\(morning.fatigueLevel)/5")
                    LabeledContent("勤務", value: String(format: "%.1f 時間", morning.workHours))
                    LabeledContent("残業", value: morning.hadOvertime ? "あり" : "なし")
                    Text(morning.physicalConditionMemo)
                } else {
                    Text("未入力")
                }
            }

            Section("練習後入力") {
                if let training = status.record?.trainingLog {
                    LabeledContent("実施", value: training.didTrain ? "あり" : "なし")
                    LabeledContent("メニュー", value: training.menuName)
                    LabeledContent("RPE", value: "\(training.rpe)/10")
                    LabeledContent("痛み", value: training.hasPain ? "あり" : "なし")
                    if training.hasPain {
                        LabeledContent("部位", value: training.painArea)
                    }
                    Text(training.trainingMemo)
                } else {
                    Text("未入力")
                }
            }

            Section("コメント送信") {
                TextField("指導者名", text: $coachName)
                TextField("コメント", text: $commentText, axis: .vertical)
                    .lineLimit(2...4)

                Button("コメントを保存") {
                    guard !commentText.isEmpty else { return }
                    store.addComment(athleteID: status.athlete.id, author: coachName, message: commentText)
                    commentText = ""
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .navigationTitle("選手詳細")
    }
}
