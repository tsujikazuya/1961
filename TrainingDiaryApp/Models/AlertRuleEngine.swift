import Foundation

struct AlertRuleEngine {
    func evaluate(record: DailyRecord?) -> (AlertLevel, [String]) {
        guard let record else {
            return (.caution, ["今日の入力が未完了"])
        }

        var reasons: [String] = []

        if let morning = record.morningCheckIn {
            if morning.sleepHours < 5 {
                reasons.append("睡眠5時間未満")
            }
            if morning.fatigueLevel >= 4 {
                reasons.append("疲労感が高い")
            }
            if morning.hadOvertime {
                reasons.append("残業あり")
            }
        }

        if let training = record.trainingLog {
            if training.hasPain {
                reasons.append("痛みあり")
            }
            if training.rpe >= 8 {
                reasons.append("RPEが高い")
            }
        }

        switch reasons.count {
        case 0:
            return (.normal, ["問題なし"])
        case 1:
            return (.caution, reasons)
        default:
            return (.warning, reasons)
        }
    }
}
