import SwiftUI

struct TrainingLogView: View {
    @EnvironmentObject private var store: DiaryStore
    @Environment(\.dismiss) private var dismiss

    let athlete: Athlete

    @State private var didTrain = true
    @State private var menuName = ""
    @State private var distanceKm: Double = 5
    @State private var durationMinutes = 45
    @State private var rpe = 5
    @State private var hasPain = false
    @State private var painArea = ""
    @State private var trainingMemo = ""

    var body: some View {
        Form {
            Section("練習実施") {
                Toggle("練習を実施した", isOn: $didTrain)
                TextField("メニュー名", text: $menuName)
                if didTrain {
                    HStack {
                        Text("距離")
                        Spacer()
                        Text(String(format: "%.1f km", distanceKm))
                    }
                    Slider(value: $distanceKm, in: 0...30, step: 0.5)

                    Stepper("時間: \(durationMinutes) 分", value: $durationMinutes, in: 0...240, step: 5)
                    RatingInputRow(title: "RPE", range: 1...10, value: $rpe)
                }
            }

            Section("痛み") {
                Toggle("痛みあり", isOn: $hasPain)
                if hasPain {
                    TextField("痛み部位", text: $painArea)
                }
            }

            Section("メモ") {
                TextField("練習メモ", text: $trainingMemo, axis: .vertical)
                    .lineLimit(2...4)
            }

            Button("保存する") {
                let log = TrainingLog(
                    date: Date(),
                    didTrain: didTrain,
                    menuName: menuName,
                    distanceKm: didTrain ? distanceKm : nil,
                    durationMinutes: didTrain ? durationMinutes : nil,
                    rpe: didTrain ? rpe : 1,
                    hasPain: hasPain,
                    painArea: hasPain ? painArea : "",
                    trainingMemo: trainingMemo
                )
                store.updateTrainingLog(for: athlete.id, trainingLog: log)
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .navigationTitle("練習後入力")
    }
}
