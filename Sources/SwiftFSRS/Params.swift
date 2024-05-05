import Foundation

public struct Params {
    public var decay: Double
    public var factor: Double
    public var requestRetention: Double
    
    /// Maximum review interval in days.
    public var maximumInterval: Double
    
    /// Weights.
    public var w: [Double]
    
    public init() {
        self.decay = -0.5
        self.factor = pow(0.9, (1.0 / self.decay)) - 1.0
        self.requestRetention = 0.9
        self.maximumInterval = 36500
        self.w = [
            0.4, // Initial Stability for Again
            0.6, // Initial Stability for Hard
            2.4, // Initial Stability for Good
            5.8, // Initial Stability for Easy
            4.93,
            0.94,
            0.86,
            0.01,
            1.49,
            0.14,
            0.94,
            2.18,
            0.05,
            0.34,
            1.26,
            0.29,
            2.61,
        ]
    }
}
