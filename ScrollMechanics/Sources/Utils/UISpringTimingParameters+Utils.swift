import UIKit


extension UISpringTimingParameters {
        
    convenience init(mass: CGFloat, stiffness: CGFloat, dampingRatio: CGFloat, initialVelocity velocity: CGVector) {
        let damping = 2 * dampingRatio * sqrt(mass * stiffness)
        self.init(mass: mass, stiffness: stiffness, damping: damping, initialVelocity: velocity)
    }
    
}
