import Foundation
import CoreGraphics

public func rubberBandClamp(_ x: CGFloat, coeff: CGFloat, dim: CGFloat) -> CGFloat {
    return (1.0 - (1.0 / (x * coeff / dim + 1.0))) * dim
}

public func rubberBandClamp(_ x: CGFloat, coeff: CGFloat, limits: ClosedRange<CGFloat>) -> CGFloat {
    let clampedX = x.clamped(to: limits)
    let diff = abs(x - clampedX)
    let sign: CGFloat = clampedX > x ? -1 : 1
    let dim = limits.upperBound - limits.lowerBound
    return clampedX + sign * rubberBandClamp(diff, coeff: coeff, dim: dim)
}

public struct RubberBand {
    public var coeff: CGFloat
    public var bounds: CGRect
    
    public init(coeff: CGFloat = 0.55, bounds: CGRect) {
        self.coeff = coeff
        self.bounds = bounds
    }
    
    public func clamp(_ point: CGPoint) -> CGPoint {
        let x = rubberBandClamp(point.x, coeff: coeff, limits: bounds.minX...bounds.maxX)
        let y = rubberBandClamp(point.y, coeff: coeff, limits: bounds.minY...bounds.maxY)
        return CGPoint(x: x, y: y)
    }
}
