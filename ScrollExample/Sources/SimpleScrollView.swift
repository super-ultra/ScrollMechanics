import UIKit
import ScrollMechanics

class SimpleScrollView: UIView {
    
    var contentView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            
            if let contentView = contentView {
                addSubview(contentView)
                contentView.frame = CGRect(origin: contentOrigin, size: contentSize)
            }
        }
    }
    
    var contentSize: CGSize = .zero {
        didSet {
            contentView?.frame.size = contentSize
        }
    }
    
    var contentOffset: CGPoint = .zero {
        didSet {
            contentView?.frame.origin = contentOrigin
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private

    private enum State {
        case `default`
        case dragging(initialOffset: CGPoint)
    }

    private var contentOrigin: CGPoint { return CGPoint(x: -contentOffset.x, y: -contentOffset.y) }
    
    private var contentOffsetBounds: CGRect {
        let width = contentSize.width - bounds.width
        let height = contentSize.height - bounds.height
        return CGRect(x: 0, y: 0, width: width, height: height)
    }
    
    private let panRecognizer = UIPanGestureRecognizer()
    
    private var state: State = .default
    
    private var contentOffsetAnimation: TimerAnimation?

    private func setup() {
        addGestureRecognizer(panRecognizer)
        panRecognizer.addTarget(self, action: #selector(handlePanRecognizer))
    }
    
    @objc private func handlePanRecognizer(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            stopOffsetAnimation()
            state = .dragging(initialOffset: contentOffset)
        
        case .changed:
            let translation = sender.translation(in: self)
            if case .dragging(let initialOffset) = state {
                contentOffset = clampOffset(initialOffset - translation)
            }
        
        case .ended:
            state = .default
            let velocity = sender.velocity(in: self)
            completeGesture(withVelocity: -velocity)
            
        case .cancelled, .failed:
            state = .default
            
        case .possible:
            break
        
        @unknown default:
            fatalError()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        // Freeze the scroll view at its current position so that the user can
        // interact with its content or scroll it.
        stopOffsetAnimation()
    }
    
    private func stopOffsetAnimation() {
        contentOffsetAnimation?.invalidate()
        contentOffsetAnimation = nil
    }
    
    private func startDeceleration(withVelocity velocity: CGPoint) {
        let d = UIScrollView.DecelerationRate.normal.rawValue
        let parameters = DecelerationTimingParameters(initialValue: contentOffset, initialVelocity: velocity,
                                                      decelerationRate: d, threshold: 0.5)
                                                      
        let destination = parameters.destination
        let intersection = getIntersection(rect: contentOffsetBounds, segment: (contentOffset, destination))
        
        let duration: TimeInterval
        
        if let intersection = intersection, let intersectionDuration = parameters.duration(to: intersection) {
            duration = intersectionDuration
        } else {
            duration = parameters.duration
        }
        
        contentOffsetAnimation = TimerAnimation(
            duration: duration,
            animations: { [weak self] _, time in
                self?.contentOffset = parameters.value(at: time)
            },
            completion: { [weak self] finished in
                guard finished && intersection != nil else { return }
                let velocity = parameters.velocity(at: duration)
                self?.bounce(withVelocity: velocity)
            })
    }
    
    private func bounce(withVelocity velocity: CGPoint) {
        let restOffset = contentOffset.clamped(to: contentOffsetBounds)
        let displacement = contentOffset - restOffset
        let threshold = 0.5 / UIScreen.main.scale
        let spring = Spring(mass: 1, stiffness: 100, dampingRatio: 1)
        
        let parameters = SpringTimingParameters(spring: spring,
                                                displacement: displacement,
                                                initialVelocity: velocity,
                                                threshold: threshold)
       
        contentOffsetAnimation = TimerAnimation(
            duration: parameters.duration,
            animations: { [weak self] _, time in
                self?.contentOffset = restOffset + parameters.value(at: time)
            })
    }

    private func clampOffset(_ offset: CGPoint) -> CGPoint {
        let rubberBand = RubberBand(dims: bounds.size, bounds: contentOffsetBounds)
        return rubberBand.clamp(offset)
    }
    
    private func completeGesture(withVelocity velocity: CGPoint) {
        if contentOffsetBounds.containsIncludingBorders(contentOffset) {
            startDeceleration(withVelocity: velocity)
        } else {
            bounce(withVelocity: velocity)
        }
    }
    
}
