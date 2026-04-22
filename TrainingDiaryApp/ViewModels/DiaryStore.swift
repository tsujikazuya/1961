import Foundation

@MainActor
final class DiaryStore: ObservableObject {
    @Published var athletes: [Athlete] = []
    @Published var dailyRecords: [DailyRecord] = []
    @Published var comments: [CoachComment] = []

    private let repository: DiaryRepository
    private let alertEngine = AlertRuleEngine()

    init(repository: DiaryRepository = InMemoryDiaryRepository()) {
        self.repository = repository
        load()
    }

    func load() {
        athletes = repository.fetchAthletes()
        dailyRecords = repository.fetchDailyRecords()
        comments = repository.fetchComments()
    }

    func record(for athleteID: UUID, date: Date = Date()) -> DailyRecord? {
        let day = Calendar.current.startOfDay(for: date)
        return dailyRecords.first { $0.athleteID == athleteID && Calendar.current.isDate($0.date, inSameDayAs: day) }
    }

    func statusList(for date: Date = Date()) -> [AthleteDailyStatus] {
        athletes.map { athlete in
            let target = record(for: athlete.id, date: date)
            let (level, reasons) = alertEngine.evaluate(record: target)
            return AthleteDailyStatus(athlete: athlete, record: target, alertLevel: level, alertReasons: reasons)
        }
    }

    func updateMorningCheckIn(for athleteID: UUID, checkIn: MorningCheckIn) {
        upsertRecord(for: athleteID) { $0.morningCheckIn = checkIn }
    }

    func updateTrainingLog(for athleteID: UUID, trainingLog: TrainingLog) {
        upsertRecord(for: athleteID) { $0.trainingLog = trainingLog }
    }

    func addComment(athleteID: UUID, author: String, message: String) {
        let newComment = CoachComment(
            id: UUID(),
            athleteID: athleteID,
            date: Date(),
            authorName: author,
            message: message
        )
        comments.insert(newComment, at: 0)
    }

    func comments(for athleteID: UUID) -> [CoachComment] {
        comments
            .filter { $0.athleteID == athleteID }
            .sorted { $0.date > $1.date }
    }

    private func upsertRecord(for athleteID: UUID, update: (inout DailyRecord) -> Void) {
        let today = Calendar.current.startOfDay(for: Date())

        if let index = dailyRecords.firstIndex(where: { $0.athleteID == athleteID && Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            update(&dailyRecords[index])
        } else {
            var newRecord = DailyRecord(id: UUID(), athleteID: athleteID, date: today, morningCheckIn: nil, trainingLog: nil)
            update(&newRecord)
            dailyRecords.append(newRecord)
        }
    }
}
