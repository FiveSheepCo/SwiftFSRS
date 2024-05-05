import Foundation

public struct ReviewLog: Equatable, Codable {
    public var rating: Rating
    public var elapsedDays: Double
    public var scheduledDays: Double
    public var review: Date
    public var status: Status
    
    public init(
        rating: Rating,
        elapsedDays: Double,
        scheduledDays: Double,
        review: Date,
        status: Status
    ) {
        self.rating = rating
        self.elapsedDays = elapsedDays
        self.scheduledDays = scheduledDays
        self.review = review
        self.status = status
    }
}
