import SwiftUI

struct AthleteHomeView: View {
    @EnvironmentObject private var store: DiaryStore
    let athlete: Athlete

    var body: some View {
        NavigationStack {
            List {
                Section("今日の入力") {
                    NavigationLink("朝チェックインを入力") {
                        MorningCheckInView(athlete: athlete)
                    }
                    NavigationLink("練習後入力を記録") {
                        TrainingLogView(athlete: athlete)
                    }
                }

                Section("指導者コメント") {
                    NavigationLink("コメントを確認") {
                        CommentListView(athlete: athlete)
                    }
                }

                if let status = store.statusList().first(where: { $0.athlete.id == athlete.id }) {
                    Section("今日の状態") {
                        HStack {
                            Text("判定")
                            Spacer()
                            AlertBadgeView(level: status.alertLevel)
                        }
                        Text(status.alertReasons.joined(separator: " / "))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("選手ホーム")
        }
    }
}
