import UIKit

class ViewController: UIViewController {

    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateDebugState()
    }

    // MARK: - Private
    
    private let bgImageView = UIImageView()
    private var pipContainer = PipContainer()
    
    private var isDebug = true {
        didSet {
            updateDebugState()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(bgImageView)
        bgImageView.contentMode = .scaleAspectFill
        
        view.addSubview(pipContainer)
        
        setupLayout()
    }
    
    private func setupLayout() {
        let inset: CGFloat = 24
        
        pipContainer.translatesAutoresizingMaskIntoConstraints = false
        pipContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: inset)
            .isActive = true
        pipContainer.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: inset)
            .isActive = true
        pipContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -inset)
            .isActive = true
        pipContainer.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -inset)
            .isActive = true
            
        bgImageView.translatesAutoresizingMaskIntoConstraints = false
        bgImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bgImageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        bgImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bgImageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    private func updateDebugState() {
        pipContainer.isDebug = isDebug
        bgImageView.image = isDebug ? nil : UIImage(named: "face_02")
    }

}
