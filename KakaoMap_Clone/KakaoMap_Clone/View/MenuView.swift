//
//  MenuView.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/06/04.
//

import Foundation

final class MenuView: UIView {
    
    private let profileImage: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .systemBlue
        return iv
    }()
    
    private let profileName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "닉네임"
        return label
    }()
    // 프로필 관련된 부분만 담은 연한 회색의 header view
    private lazy var profileHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray.withAlphaComponent(0.3)
        [profileImage, profileName].forEach(view.addSubview)
        return view
    }()
    
    private let reviewButton = MenuOptionsButton(text: "작성한 후기")
    
    private let favoritesButton = MenuOptionsButton(text: "즐겨찾기")
    
    private let settingsButton = MenuOptionsButton(text: "설정")
    
    private lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView()
        [reviewButton, favoritesButton, settingsButton].forEach(stack.addArrangedSubview)
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 16
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var menuView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        [profileHeaderView, buttonsStackView].forEach(view.addSubview)
        return view
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setAutolayout()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        self.backgroundColor = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 0.3)
    }
    
    private func setAutolayout() {
        self.addSubview(menuView)
        menuView.anchor(left: self.leftAnchor,
                        width: (self.frame.width / 3) * 2,
                        height: self.frame.height)
        print(menuView.frame.width)
        profileHeaderView.anchor(top: menuView.topAnchor,
                                 width: (self.frame.width / 3) * 2,
                                 height: frame.height / 4)
        
        buttonsStackView.anchor(top: profileHeaderView.bottomAnchor,
                                paddingTop: 20)
        buttonsStackView.centerX(inView: self)
        
        profileImage.centerY(inView: profileHeaderView)
        profileImage.anchor(left: profileHeaderView.leftAnchor,
                            paddingLeft: 18,
                            width: 30,
                            height: 30)
        
        profileName.anchor(top: profileImage.topAnchor,
                           left: profileImage.rightAnchor,
                           paddingLeft: 10)
    }
    
    func getMenuView() -> UIView {
        return menuView
    }
}
