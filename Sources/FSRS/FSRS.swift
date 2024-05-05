import Foundation

public struct FSRS {
    public var p: Params

    public init(p: Params = Params()) {
        self.p = p
    }
}

public extension FSRS {
    func `repeat`(card: Card, now: Date) -> [Rating: SchedulingInfo] {
        var card = card
        
        if card.status == .new {
            card.elapsedDays = 0
        } else {
            card.elapsedDays = max(0, (now.timeIntervalSince(card.lastReview)) / Constants.secondsInDay)
        }
        
        card.lastReview = now
        card.reps += 1
        
        var s = SchedulingCards(card: card)
        s.updateStatus(to: card.status)
        
        switch card.status {
            case .new:
                initDS(s: &s)
                
                s.again.due = s.addTime(now, value: 1, unit: .minute)
                s.hard.due = s.addTime(now, value: 5, unit: .minute)
                s.good.due = s.addTime(now, value: 10, unit: .minute)
                
                let easyInterval = nextInterval(s: s.easy.stability)
                
                s.easy.scheduledDays = easyInterval
                s.easy.due = s.addTime(now, value: easyInterval, unit: .day)
                
            case .learning, .relearning:
                let hardInterval = 0.0
                let goodInterval = nextInterval(s: s.good.stability)
                let easyInterval = max(nextInterval(s: s.easy.stability), goodInterval + 1)
                s.schedule(now: now, hardInterval: hardInterval, goodInterval: goodInterval, easyInterval: easyInterval)
                
            case .review:
                let retrievability = card.forgettingCurve(params: p)
                nextDS(&s, lastDifficulty: card.difficulty, lastStability: card.stability, retrievability: retrievability)
                
                var hardInterval = nextInterval(s: s.hard.stability)
                var goodInterval = nextInterval(s: s.good.stability)
                
                hardInterval = min(hardInterval, goodInterval)
                goodInterval = max(goodInterval, hardInterval + 1)
                
                let easyInterval = max(nextInterval(s: s.easy.stability), goodInterval + 1)
                s.schedule(now: now, hardInterval: hardInterval, goodInterval: goodInterval, easyInterval: easyInterval)
        }
        
        return s.recordLog(for: card, now: now)
    }
    
    func initDS(s: inout SchedulingCards) {
        s.again.difficulty = initDifficulty(.again)
        s.again.stability = initStability(.again)
        s.hard.difficulty = initDifficulty(.hard)
        s.hard.stability = initStability(.hard)
        s.good.difficulty = initDifficulty(.good)
        s.good.stability = initStability(.good)
        s.easy.difficulty = initDifficulty(.easy)
        s.easy.stability = initStability(.easy)
    }
    
    func nextDS(
        _ scheduling: inout SchedulingCards,
        lastDifficulty d: Double,
        lastStability s: Double,
        retrievability: Double
    ) {
        scheduling.again.difficulty = nextDifficulty(d: d, rating: .again)
        scheduling.again.stability = nextForgetStability(d: scheduling.again.difficulty, s: s, r: retrievability)
        scheduling.hard.difficulty = nextDifficulty(d: d, rating: .hard)
        scheduling.hard.stability = nextRecallStability(
            d: scheduling.hard.difficulty, s: s, r: retrievability, rating: .hard
        )
        scheduling.good.difficulty = nextDifficulty(d: d, rating: .good)
        scheduling.good.stability = nextRecallStability(
            d: scheduling.good.difficulty, s: s, r: retrievability, rating: .good
        )
        scheduling.easy.difficulty = nextDifficulty(d: d, rating: .easy)
        scheduling.easy.stability = nextRecallStability(
            d: scheduling.easy.difficulty, s: s, r: retrievability, rating: .easy
        )
    }
    
    func initStability(_ rating: Rating) -> Double {
        initStability(r: rating.rawValue)
    }
    
    func initStability(r: Int) -> Double {
        max(p.w[r - 1], 0.1)
    }
    
    func initDifficulty(_ rating: Rating) -> Double {
        initDifficulty(r: rating.rawValue)
    }
    
    func initDifficulty(r: Int) -> Double {
        min(max(p.w[4] - p.w[5] * Double(r - 3), 1.0), 10.0)
    }
    
    func nextInterval(s: Double) -> Double {
        let ivl = (s / p.factor) * (pow(p.requestRetention, 1.0 / p.decay) - 1.0)
        return constrainInterval(ivl: ivl)
    }
    
    func nextDifficulty(d: Double, rating: Rating) -> Double {
        let r = rating.rawValue
        let nextD = d - p.w[6] * Double(r - 3)
        return constrainDifficulty(meanReversion(p.w[4], current: nextD))
    }
    
    func nextRecallStability(d: Double, s: Double, r: Double, rating: Rating) -> Double {
        let hardPenalty = (rating == .hard) ? p.w[15] : 1
        let easyBonus = (rating == .easy) ? p.w[16] : 1
        return s * (
            1
            + exp(p.w[8])
            * (11 - d)
            * pow(s, -p.w[9])
            * (exp((1 - r) * p.w[10]) - 1)
            * hardPenalty
            * easyBonus
        )
    }
    
    func nextForgetStability(d: Double, s: Double, r: Double) -> Double {
        let fs = (
            p.w[11]
            * pow(d, -p.w[12])
            * (pow(s + 1.0, p.w[13]) - 1)
            * exp((1.0 - r) * p.w[14])
        )
        return min(fs, s)
    }
}

internal extension FSRS {
    func constrainDifficulty(_ d: Double) -> Double {
        min(max(d, 1), 10)
    }
    
    func constrainInterval(ivl: Double) -> Double {
        min(max(round(ivl), 1), p.maximumInterval)
    }
    
    func meanReversion(_ initial: Double, current: Double) -> Double {
        p.w[7] * initial + (1 - p.w[7]) * current
    }
}
