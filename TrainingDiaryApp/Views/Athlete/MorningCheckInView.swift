import SwiftUI

struct MorningCheckInView: View {
    @EnvironmentObject private var store: DiaryStore
    @Environment(\.dismiss) private var dismiss

    let athlete: Athlete

    @State private var sleepHours: Double = 6
    @State private var sleepQuality = 3
    @State private var fatigueLevel = 3
    @State private var muscleSoreness = 3
    @State private var moodLevel = 3
    @State private var physicalConditionMemo = ""
    @State private var workHours: Double = 8
    @State private var hadOvertime = false
    @State private var workStressLevel = 3

    var body: some View {
        Form {
            Section("睡眠") {
                HStack {
                    Text("睡眠時間")
                    Spacer()
                    Text(String(format: "%.1f 時間", sleepHours))
                }
                Slider(value: $sleepHours, in: 3...10, step: 0.5)
                RatingInputRow(title: "睡眠の質", range: 1...5, value: $sleepQuality)
            }

            Section("コンディション") {
                RatingInputRow(title: "疲労感", range: 1...5, value: $fatigueLevel)
                RatingInputRow(title: "筋肉痛", range: 1...5, value: $muscleSoreness)
                RatingInputRow(title: "気分", range: 1...5, value: $moodLevel)
                TextField("体調メモ", text: $physicalConditionMemo, axis: .vertical)
                    .lineLimit(2...4)
            }

            Section("勤務負荷") {
                HStack {
                    Text("勤務時間")
                    Spacer()
                    Text(String(format: "%.1f 時間", workHours))
                }
                Slider(value: $workHours, in: 4...14, step: 0.5)
                Toggle("残業あり", isOn: $hadOvertime)
                RatingInputRow(title: "仕事ストレス", range: 1...5, value: $workStressLevel)
            }

            Button("保存する") {
                let checkIn = MorningCheckIn(
                    date: Date(),
                    sleepHours: sleepHours,
                    sleepQuality: sleepQuality,
                    fatigueLevel: fatigueLevel,
                    muscleSoreness: muscleSoreness,
                    moodLevel: moodLevel,
                    physicalConditionMemo: physicalConditionMemo,
                    workHours: workHours,
                    hadOvertime: hadOvertime,
                    workStressLevel: workStressLevel
                )
                store.updateMorningCheckIn(for: athlete.id, checkIn: checkIn)
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .navigationTitle("朝チェックイン")
    }
}
