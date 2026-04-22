import SwiftUI

@main
struct TrainingDiaryApp: App {
    @StateObject private var store = DiaryStore()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(store)
        }
    }
}
