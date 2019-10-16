import UIKit


final class PipPlaceholder: UIView {

//    var cornerRadius: CGFloat {
//        get { layer.cornerRadius }
//        set { layer.cornerRadius = newValue }
//    }
//    
//    var isHighlighted: Bool {
//        get { isHighlighted_ }
//        set { setHighlighted(newValue, animated: false) }
//    }

    init(cornerRadius: CGFloat) {
        super.init(frame: .zero)
        
       layer.cornerRadius = cornerRadius
       layer.borderColor = UIColor.gray.cgColor
       layer.borderWidth = 2
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted == isHighlighted_ {
            return
        }
        
        isHighlighted_ = highlighted
        
        let actions: () -> Void = { [weak self] in
            self?.backgroundColor = highlighted ? UIColor.gray.withAlphaComponent(0.5) : UIColor.clear
        }
        
        if animated {
            UIView.animate(withDuration: 0.25) {
                actions()
            }
        } else {
            actions()
        }
    }
    
    // MARK: - Private
    
    private var isHighlighted_: Bool = false
    
}
