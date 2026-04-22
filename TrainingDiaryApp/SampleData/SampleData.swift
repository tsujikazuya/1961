import Foundation

enum SampleData {
    static let athletes: [Athlete] = [
        Athlete(id: UUID(uuidString: "D2A0D6A8-7EF4-4F81-BE95-7B96D2A7A001")!, name: "山田 太郎", company: "淡路建設", event: "短距離"),
        Athlete(id: UUID(uuidString: "D2A0D6A8-7EF4-4F81-BE95-7B96D2A7A002")!, name: "佐藤 花子", company: "淡路食品", event: "中距離"),
        Athlete(id: UUID(uuidString: "D2A0D6A8-7EF4-4F81-BE95-7B96D2A7A003")!, name: "鈴木 一樹", company: "淡路運輸", event: "長距離")
    ]

    static let dailyRecords: [DailyRecord] = {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return [
            DailyRecord(
                id: UUID(),
                athleteID: athletes[0].id,
                date: today,
                morningCheckIn: MorningCheckIn(
                    date: today,
                    sleepHours: 4.8,
                    sleepQuality: 2,
                    fatigueLevel: 4,
                    muscleSoreness: 3,
                    moodLevel: 3,
                    physicalConditionMemo: "やや頭重感あり",
                    workHours: 9.5,
                    hadOvertime: true,
                    workStressLevel: 4
                ),
                trainingLog: TrainingLog(
                    date: today,
                    didTrain: true,
                    menuName: "インターバル走",
                    distanceKm: 8.0,
                    durationMinutes: 55,
                    rpe: 8,
                    hasPain: true,
                    painArea: "右ハムストリング",
                    trainingMemo: "後半で張りを感じたため本数を減らした"
                )
            ),
            DailyRecord(
                id: UUID(),
                athleteID: athletes[1].id,
                date: today,
                morningCheckIn: MorningCheckIn(
                    date: today,
                    sleepHours: 6.5,
                    sleepQuality: 4,
                    fatigueLevel: 2,
                    muscleSoreness: 2,
                    moodLevel: 4,
                    physicalConditionMemo: "体調良好",
                    workHours: 8.0,
                    hadOvertime: false,
                    workStressLevel: 2
                ),
                trainingLog: TrainingLog(
                    date: today,
                    didTrain: true,
                    menuName: "ペース走",
                    distanceKm: 10.0,
                    durationMinutes: 48,
                    rpe: 6,
                    hasPain: false,
                    painArea: "",
                    trainingMemo: "予定通り完了"
                )
            ),
            DailyRecord(
                id: UUID(),
                athleteID: athletes[2].id,
                date: today,
                morningCheckIn: MorningCheckIn(
                    date: today,
                    sleepHours: 5.4,
                    sleepQuality: 3,
                    fatigueLevel: 3,
                    muscleSoreness: 3,
                    moodLevel: 3,
                    physicalConditionMemo: "少し脚が重い",
                    workHours: 10.0,
                    hadOvertime: true,
                    workStressLevel: 3
                ),
                trainingLog: nil
            )
        ]
    }()

    static let comments: [CoachComment] = [
        CoachComment(
            id: UUID(),
            athleteID: athletes[0].id,
            date: Date(),
            authorName: "田中コーチ",
            message: "右もものケアを最優先に。明日はジョグのみでOKです。"
        ),
        CoachComment(
            id: UUID(),
            athleteID: athletes[1].id,
            date: Date(),
            authorName: "田中コーチ",
            message: "良い流れです。明日はペース維持を意識しましょう。"
        )
    ]
}
