import UIKit
import ScrollMechanics

final class PipContainer: UIView {

    var isDebug: Bool = false {
        didSet {
            updateDebugState()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        updateDebugState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private:
    
    private enum Corner: CaseIterable {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }
    
    private enum PipState: Equatable {
        case `default`
        case dragging(initialOrigin: CGPoint)
    }
    
    private struct Static {
        static let pipSize = CGSize(width: 100, height: 180)
        static let pipCornerRadius = CGFloat(20)
    }
    
    private var corner = Corner.topLeft
    private var pipState = PipState.default
    
    private let pipView = PipView(cornerRadius: Static.pipCornerRadius)
    private let tlPipPlaceholder = PipPlaceholder(cornerRadius: Static.pipCornerRadius)
    private let trPipPlaceholder = PipPlaceholder(cornerRadius: Static.pipCornerRadius)
    private let blPipPlaceholder = PipPlaceholder(cornerRadius: Static.pipCornerRadius)
    private let brPipPlaceholder = PipPlaceholder(cornerRadius: Static.pipCornerRadius)
    
    private let pipPanRecognizer = UIPanGestureRecognizer()
    
    private func setupUI() {
        backgroundColor = .clear

        forEachPipPlaceholder {
            addSubview($0)
        }
    
        addSubview(pipView)
        pipView.addGestureRecognizer(pipPanRecognizer)
        pipPanRecognizer.addTarget(self, action: #selector(handlePipPanRecognizer))
    
        setupLayout()
    }
    
    private func setupLayout() {
        pipView.frame.size = Static.pipSize
        pipOrigin = pipOrigin(for: corner)
        
        forEachPipPlaceholder {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.widthAnchor.constraint(equalToConstant: Static.pipSize.width).isActive = true
            $0.heightAnchor.constraint(equalToConstant: Static.pipSize.height).isActive = true
        }
        
        tlPipPlaceholder.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tlPipPlaceholder.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
        trPipPlaceholder.topAnchor.constraint(equalTo: topAnchor).isActive = true
        trPipPlaceholder.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        blPipPlaceholder.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        blPipPlaceholder.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
        brPipPlaceholder.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        brPipPlaceholder.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
    
    private func updateDebugState() {
        pipView.image = isDebug ? nil : UIImage(named: "face_01")
        
        
        forEachPipPlaceholder {
            $0.isHidden = !isDebug
        }
    }
    
    // MARK: - Private: Pip
    
    private var pipAnimation: TimerAnimation?
    
    private var pipOrigin: CGPoint = .zero {
        didSet {
            pipView.frame.origin = pipOrigin
            updatePlaceholders()
        }
    }
    
    private func updatePipOrigin(with origin: CGPoint, velocity: CGPoint = .zero, animated: Bool = false) {
        guard animated else {
            pipOrigin = origin
            return
        }
    
        let from = pipOrigin
        let to = origin
    
        let parameters = SpringTimingParameters(spring: .default,
                                                displacement: from - to,
                                                initialVelocity: velocity,
                                                threshold: 0.5)
        
        let duration = parameters.duration
    
        pipAnimation = TimerAnimation(duration: duration, animations: { [weak self] _, time in
            self?.pipOrigin = to + parameters.value(at: time)
        })
    }
    
    private func stopPipOriginAnimation() {
        pipAnimation?.invalidate()
        pipAnimation = nil
    }
    
    @objc private func handlePipPanRecognizer(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            stopPipOriginAnimation()
            pipState = .dragging(initialOrigin: pipOrigin)
        
        case .changed:
            let translation = sender.translation(in: pipView)
        
            if case .dragging(let initialOrigin) = pipState {
                pipOrigin = initialOrigin + translation
            }
        
        case .ended:
            pipState = .default
            
            let velocity = sender.velocity(in: pipView)
            let projection = projectPipOrigin(withInitialOrigin: pipOrigin, velocity: velocity)
            let newCorner = nearestCorner(forOrigin: projection)
            let newOrigin = pipOrigin(for: newCorner)
            updatePipOrigin(with: newOrigin, velocity: velocity, animated: true)
            
        case .cancelled, .failed:
            pipState = .default
            
        case .possible:
            break
        
        @unknown default:
            fatalError()
        }
    }
    
    private func pipOrigin(for corner: Corner) -> CGPoint {
        let pipSize = Static.pipSize
        
        switch corner {
        case .topLeft:
            return CGPoint(x: 0, y: 0)
        case .topRight:
            return CGPoint(x: bounds.width - pipSize.width, y: 0)
        case .bottomLeft:
            return CGPoint(x: 0, y: bounds.height - pipSize.height)
        case .bottomRight:
            return CGPoint(x: bounds.width - pipSize.width, y: bounds.height - pipSize.height)
        }
    }
    
    private func nearestCorner(forOrigin origin: CGPoint) -> Corner {
        return Corner.allCases.min(by: {
            pipOrigin(for: $0).distance(to: origin) < pipOrigin(for: $1).distance(to: origin)
        }) ?? .topLeft
    }
    
    private func projectPipOrigin(withInitialOrigin initialOrigin: CGPoint, velocity: CGPoint) -> CGPoint {
        let decelerationRate = UIScrollView.DecelerationRate.normal.rawValue
        let parameters = DecelerationTimingParameters(initialValue: initialOrigin, initialVelocity: velocity,
                                                      decelerationRate: decelerationRate, threshold: 0.1)
        return parameters.destination
    }
    
    // MARK: - Private: Placeholders
    
    private func forEachPipPlaceholder(_ action: (PipPlaceholder) -> Void) {
        for v in [tlPipPlaceholder, trPipPlaceholder, blPipPlaceholder, brPipPlaceholder] {
            action(v)
        }
    }
    
    private func placeholder(for corner: Corner) -> PipPlaceholder {
        switch corner {
        case .topLeft:
            return tlPipPlaceholder
        case .topRight:
            return trPipPlaceholder
        case .bottomLeft:
            return blPipPlaceholder
        case .bottomRight:
            return brPipPlaceholder
        }
    }
    
    private func updatePlaceholders() {
        let cornerToHighlight = nearestCorner(forOrigin: pipOrigin)
        for c in Corner.allCases {
            placeholder(for: c).setHighlighted(c == cornerToHighlight, animated: true)
        }
    }
    
}
