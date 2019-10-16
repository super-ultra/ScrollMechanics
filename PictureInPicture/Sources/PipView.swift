import UIKit
import ScrollMechanics


final class PipView: UIView {

    var cornerRadius: CGFloat {
        get { layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }

    var image: UIImage? {
        get { imageView.image }
        set { imageView.image = newValue }
    }

    init(cornerRadius: CGFloat) {
        super.init(frame: .zero)
                
        layer.cornerRadius = cornerRadius
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    private let imageView = UIImageView()

    private func setupUI() {
        backgroundColor = UIColor(red: 1, green: 0.8, blue: 0, alpha: 1)
        layer.masksToBounds = true
        
        addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]   
    }

}
