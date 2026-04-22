import Foundation

struct Athlete: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var company: String
    var event: String
}

struct MorningCheckIn: Codable, Hashable {
    var date: Date
    var sleepHours: Double
    var sleepQuality: Int
    var fatigueLevel: Int
    var muscleSoreness: Int
    var moodLevel: Int
    var physicalConditionMemo: String
    var workHours: Double
    var hadOvertime: Bool
    var workStressLevel: Int
}

struct TrainingLog: Codable, Hashable {
    var date: Date
    var didTrain: Bool
    var menuName: String
    var distanceKm: Double?
    var durationMinutes: Int?
    var rpe: Int
    var hasPain: Bool
    var painArea: String
    var trainingMemo: String
}

struct CoachComment: Identifiable, Codable, Hashable {
    let id: UUID
    var athleteID: UUID
    var date: Date
    var authorName: String
    var message: String
}

struct DailyRecord: Identifiable, Codable, Hashable {
    let id: UUID
    var athleteID: UUID
    var date: Date
    var morningCheckIn: MorningCheckIn?
    var trainingLog: TrainingLog?
}

enum AlertLevel: String, Codable {
    case normal
    case caution
    case warning
}

struct AthleteDailyStatus: Identifiable {
    let id = UUID()
    let athlete: Athlete
    let record: DailyRecord?
    let alertLevel: AlertLevel
    let alertReasons: [String]
}
