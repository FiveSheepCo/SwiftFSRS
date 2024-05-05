import Foundation

public struct SchedulingInfo {
    public var card: Card
    public var reviewLog: ReviewLog
    
    public init(card: Card, reviewLog: ReviewLog) {
        self.card = card
        self.reviewLog = reviewLog
    }
    
    public init(rating: Rating, reference: Card, current: Card, review: Date) {
        self.card = reference
        self.reviewLog = ReviewLog(
            rating: rating,
            elapsedDays: reference.elapsedDays,
            scheduledDays: current.scheduledDays,
            review: review,
            status: current.status
        )
    }
}
