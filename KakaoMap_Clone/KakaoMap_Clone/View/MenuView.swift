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
        iv.image = UIImage(named: "defaultUserImage")
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 25
        return iv
    }()
    
    private let profileName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.text = "로그인하세요"
        return label
    }()
    // 프로필 관련된 부분만 담은 연한 회색의 header view
    private lazy var profileHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray.withAlphaComponent(0.1)
        [profileImage, profileName].forEach(view.addSubview)
        return view
    }()
    
    private let favoritesButton = MenuOptionsButton(text: "즐겨찾기",
                                                    image: UIImage(systemName: "star"))
    
    private let loginButton = MenuOptionsButton(text: "로그인",
                                                image: UIImage(systemName: "person.circle"))
    
    private lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView()
        [favoritesButton, loginButton].forEach(stack.addArrangedSubview)
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 16
        stack.distribution = .fillEqually
        return stack
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setAutolayout()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        self.backgroundColor = .white
    }
    
    private func setAutolayout() {
        [profileHeaderView, buttonsStackView].forEach(self.addSubview)

        profileHeaderView.anchor(top: self.topAnchor,
                                 width: self.frame.width,
                                 height: self.frame.height / 4)
        
        buttonsStackView.anchor(top: profileHeaderView.bottomAnchor,
                                left: self.leftAnchor,
                                paddingTop: 20,
                                paddingLeft: 25)
        
        profileImage.anchor(top: profileHeaderView.topAnchor,
                            left: profileHeaderView.leftAnchor,
                            paddingTop: 100,
                            paddingLeft: 25,
                            width: 60,
                            height: 60)
        
        profileName.anchor(top: profileImage.topAnchor,
                           left: profileImage.rightAnchor,
                           paddingTop: 5,
                           paddingLeft: 10)
    }
    
    func configureUIwithUserData(imageURL: URL?, name: String?) {
        guard let imageURL = imageURL,
              let name = name else {
            self.profileImage.image = UIImage(named: "defaultUserImage")
            self.profileName.text = "로그인하세요"
            return
        }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let data = try? Data(contentsOf: imageURL)
            DispatchQueue.main.async {
                self?.profileImage.image = UIImage(data: data!)
                self?.profileName.text = name
            }
        }
    }

    var favoritePlaceButton: MenuOptionsButton {
        return favoritesButton
    }
    
    var userLoginButton: MenuOptionsButton {
        return loginButton
    }
}
