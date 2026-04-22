import SwiftUI

struct CommentListView: View {
    @EnvironmentObject private var store: DiaryStore
    let athlete: Athlete

    var body: some View {
        List {
            ForEach(store.comments(for: athlete.id)) { comment in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(comment.authorName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                        Text(comment.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(comment.message)
                        .font(.body)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("コメント確認")
    }
}
