import Foundation
import CoreGraphics

public protocol TimingParameters {
    var duration: TimeInterval { get }
    func value(at time: TimeInterval) -> CGPoint
}
