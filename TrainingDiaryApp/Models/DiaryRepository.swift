import Foundation

protocol DiaryRepository {
    func fetchAthletes() -> [Athlete]
    func fetchDailyRecords() -> [DailyRecord]
    func fetchComments() -> [CoachComment]
}

struct InMemoryDiaryRepository: DiaryRepository {
    func fetchAthletes() -> [Athlete] {
        SampleData.athletes
    }

    func fetchDailyRecords() -> [DailyRecord] {
        SampleData.dailyRecords
    }

    func fetchComments() -> [CoachComment] {
        SampleData.comments
    }
}
