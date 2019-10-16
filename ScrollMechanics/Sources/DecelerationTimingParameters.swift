import Foundation
import CoreGraphics

public struct DecelerationTimingParameters {
    public var initialValue: CGPoint
    public var initialVelocity: CGPoint
    public var decelerationRate: CGFloat
    public var threshold: CGFloat
    
    public init(initialValue: CGPoint, initialVelocity: CGPoint, decelerationRate: CGFloat, threshold: CGFloat) {
        assert(decelerationRate > 0 && decelerationRate < 1)
        
        self.initialValue = initialValue
        self.initialVelocity = initialVelocity
        self.decelerationRate = decelerationRate
        self.threshold = threshold
    }
}

public extension DecelerationTimingParameters {
    
    var destination: CGPoint {
        let dCoeff = 1000 * log(decelerationRate)
        return initialValue - initialVelocity / dCoeff
    }
    
    var duration: TimeInterval {
        guard initialVelocity.length > 0 else { return 0 }
        
        let dCoeff = 1000 * log(decelerationRate)
        return TimeInterval(log(-dCoeff * threshold / initialVelocity.length) / dCoeff)
    }
    
    func value(at time: TimeInterval) -> CGPoint {
        let dCoeff = 1000 * log(decelerationRate)
        return initialValue + (pow(decelerationRate, CGFloat(1000 * time)) - 1) / dCoeff * initialVelocity
    }
    
    func duration(to value: CGPoint) -> TimeInterval? {
        guard value.distance(toSegment: (initialValue, destination)) < threshold else { return nil }
        
        let dCoeff = 1000 * log(decelerationRate)
        return TimeInterval(log(1.0 + dCoeff * (value - initialValue).length / initialVelocity.length) / dCoeff)
    }
    
    func velocity(at time: TimeInterval) -> CGPoint {
        return initialVelocity * pow(decelerationRate, CGFloat(1000 * time))
    }
    
}
