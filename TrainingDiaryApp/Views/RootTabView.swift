import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var store: DiaryStore

    var body: some View {
        TabView {
            AthleteHomeView(athlete: store.athletes.first ?? Athlete(id: UUID(), name: "", company: "", event: ""))
                .tabItem {
                    Label("選手", systemImage: "figure.run")
                }

            CoachDashboardView()
                .tabItem {
                    Label("指導者", systemImage: "person.3")
                }
        }
    }
}

#Preview {
    RootTabView()
        .environmentObject(DiaryStore())
}
