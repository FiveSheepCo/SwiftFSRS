import Foundation

public struct Card: Equatable, Codable {
    public var due: Date
    public var stability: Double
    public var difficulty: Double
    public var elapsedDays: Double
    public var scheduledDays: Double
    public var reps: Int
    public var lapses: Int
    public var status: Status
    public var lastReview: Date
    
    public init(
        due: Date = Date(),
        stability: Double = 0,
        difficulty: Double = 0,
        elapsedDays: Double = 0,
        scheduledDays: Double = 0,
        reps: Int = 0,
        lapses: Int = 0,
        status: Status = .new,
        lastReview: Date = Date()
    ) {
        self.due = due
        self.stability = stability
        self.difficulty = difficulty
        self.elapsedDays = elapsedDays
        self.scheduledDays = scheduledDays
        self.reps = reps
        self.lapses = lapses
        self.status = status
        self.lastReview = lastReview
    }

    func retrievability(for now: Date, params: Params) -> Double? {
        guard status == .review else { return nil }
        let elapsedDays = max(0, (now.timeIntervalSince(lastReview) / Constants.secondsInDay))
        return forgettingCurve(elapsedDays: elapsedDays, params: params)
    }
    
    func forgettingCurve(elapsedDays: Double, params p: Params) -> Double {
        pow(1.0 + p.factor * elapsedDays / stability, p.decay)
    }
}

public extension Card {
    
    func printLog() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(self)
            print(data)
        } catch {
            print("Error serializing JSON: \(error)")
        }
    }
}
