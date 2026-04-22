import SwiftUI

struct CoachDashboardView: View {
    @EnvironmentObject private var store: DiaryStore

    var body: some View {
        NavigationStack {
            List(store.statusList()) { status in
                NavigationLink {
                    AthleteDetailView(status: status)
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(status.athlete.name)
                                    .font(.headline)
                                Text("\(status.athlete.company) / \(status.athlete.event)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            AlertBadgeView(level: status.alertLevel)
                        }

                        statusSummary(status)
                            .font(.subheadline)
                        Text(status.alertReasons.joined(separator: " / "))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("指導者ダッシュボード")
        }
    }

    @ViewBuilder
    private func statusSummary(_ status: AthleteDailyStatus) -> some View {
        let morning = status.record?.morningCheckIn
        let training = status.record?.trainingLog

        VStack(alignment: .leading, spacing: 2) {
            Text("入力状況: 朝\(morning == nil ? "✕" : "○") / 練習\(training == nil ? "✕" : "○")")
            Text("疲労: \(morning?.fatigueLevel ?? 0)  睡眠: \(String(format: "%.1f", morning?.sleepHours ?? 0))h")
            Text("勤務: \(String(format: "%.1f", morning?.workHours ?? 0))h  残業: \((morning?.hadOvertime ?? false) ? "あり" : "なし")")
            Text("練習: \((training?.didTrain ?? false) ? "実施" : "未実施")  痛み: \((training?.hasPain ?? false) ? "あり" : "なし")")
        }
    }
}
