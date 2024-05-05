import Foundation

public struct SchedulingCards: Equatable, Codable {
    public var again: Card
    public var hard: Card
    public var good: Card
    public var easy: Card
    
    public init(card: Card) {
        self.again = card
        self.hard = card
        self.good = card
        self.easy = card
    }
    
    public mutating func updateStatus(to status: Status) {
        switch status {
            case .new:
                again.status = .learning
                hard.status = .learning
                good.status = .learning
                easy.status = .review
            case .learning, .relearning:
                again.status = status
                hard.status = status
                good.status = .review
                easy.status = .review
            case .review:
                again.status = .relearning
                hard.status = .review
                good.status = .review
                easy.status = .review
                again.lapses += 1
        }
    }
    
    public mutating func schedule(
        now: Date,
        hardInterval: Double,
        goodInterval: Double,
        easyInterval: Double
    ) {
        again.scheduledDays = 0
        hard.scheduledDays = hardInterval
        good.scheduledDays = goodInterval
        easy.scheduledDays = easyInterval
        
        again.due = addTime(now, value: 5, unit: .minute)
        if hardInterval > 0 {
            hard.due = addTime(now, value: hardInterval, unit: .day)
        } else {
            hard.due = addTime(now, value: 10, unit: .minute)
        }
        good.due = addTime(now, value: goodInterval, unit: .day)
        easy.due = addTime(now, value: easyInterval, unit: .day)
    }
    
    public mutating func addTime(_ now: Date, value: Double, unit: Calendar.Component) -> Date {
        var seconds = 1.0
        switch unit {
            case .second:
                seconds = 1.0
            case .minute:
                seconds = Constants.secondsInMinute
            case .hour:
                seconds = Constants.secondsInHour
            case .day:
                seconds = Constants.secondsInDay
            default:
                assert(false)
        }
        
        return Date(timeIntervalSinceReferenceDate: now.timeIntervalSinceReferenceDate + seconds * value)
    }
    
    func recordLog(for card: Card, now: Date) -> [Rating: SchedulingInfo] {
        [
            .again: SchedulingInfo(rating: .again, reference: again, current: card, review: now),
            .hard: SchedulingInfo(rating: .hard, reference: hard, current: card, review: now),
            .good: SchedulingInfo(rating: .good, reference: good, current: card, review: now),
            .easy: SchedulingInfo(rating: .easy, reference: easy, current: card, review: now),
        ]
    }
}
