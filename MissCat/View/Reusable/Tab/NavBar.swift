//
//  NavBar.swift
//  MissCat
//
//  Created by Yuiga Wada on 2019/11/25.
//  Copyright © 2019 Yuiga Wada. All rights reserved.
//

import RxSwift
import UIKit

protocol NavBarDelegate {
    func showAccountMenu()
    func tappedRightNavButton()
    func currentUser() -> SecureUser?
}

class NavBar: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userIconView: MissCatImageView!
    @IBOutlet weak var rightButton: UIButton!
    
    private var viewModel: NavBarViewModel?
    private let disposeBag = DisposeBag()
    
    private var initialized: Bool = false
    var delegate: NavBarDelegate?
    var barTitle: String? {
        didSet {
            self.titleLabel.text = self.barTitle
        }
    }
    
    // MARK: Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
        
        let viewModel = setViewModel()
        binding(with: viewModel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
        
        let viewModel = setViewModel()
        binding(with: viewModel)
    }
    
    private func loadNib() {
        if let view = UINib(nibName: "NavBar", bundle: Bundle(for: type(of: self))).instantiate(withOwner: self, options: nil)[0] as? UIView {
            view.frame = bounds
            view.backgroundColor = .clear
            addSubview(view)
        }
    }
    
    private func setViewModel() -> NavBarViewModel {
        let viewModel = NavBarViewModel(with: nil, and: disposeBag)
        self.viewModel = viewModel
        return viewModel
    }
    
    private func binding(with viewModel: NavBarViewModel) {
        let output = viewModel.output
        output.userIcon.bind(to: userIconView.rx.image).disposed(by: disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard !initialized else { return }
        setupGesture()
        bindTheme()
        setTheme()
        userIconView.maskCircle()
        
        initialized = true
    }
    
    // MARK: Design
    
    private func bindTheme() {
        let theme = Theme.shared.theme
        
        theme.map { $0.colorPattern.ui }.subscribe(onNext: { colorPattern in
            self.backgroundColor = colorPattern.base
            self.titleLabel.textColor = colorPattern.text
        }).disposed(by: disposeBag)
    }
    
    private func setTheme() {
        if let colorPattern = Theme.shared.currentModel?.colorPattern.ui {
            backgroundColor = colorPattern.base
            titleLabel.textColor = colorPattern.text
        }
    }
    
    // Public Methods
    func setButton(style: NavBar.Button, rightText: String? = nil, leftText: String? = nil, rightFont: UIFont? = nil, leftFont: UIFont? = nil) {
        // Image
        setUserIcon()
        
        // isHidden
        rightButton.isHidden = false
        
        switch style {
        case .Both:
            break
            
        case .Right:
            break
            
        case .Left:
            rightButton.isHidden = true
            
        case .None:
            rightButton.isHidden = true
            
            return
        }
        
        // Text
        rightButton.setTitle(rightText, for: .normal)
        
        // Font
        if let rightFont = rightFont {
            rightButton.titleLabel?.font = rightFont
        }
    }
    
    private func setupGesture() {
        userIconView.setTapGesture(disposeBag, closure: {
            self.delegate?.showAccountMenu()
        })
        
        rightButton.rx.tap.subscribe { _ in
            guard let delegate = self.delegate else { return }
            delegate.tappedRightNavButton()
        }.disposed(by: disposeBag)
    }
    
    private func setUserIcon() {
        guard let user = delegate?.currentUser() else {
            userIconView.image = nil
            userIconView.isHidden = true
            return
        }
        
        userIconView.isHidden = false
        viewModel?.transform(user: user)
    }
}

extension NavBar {
    enum Button {
        case Right
        case Left
        case Both
        case None
    }
}
