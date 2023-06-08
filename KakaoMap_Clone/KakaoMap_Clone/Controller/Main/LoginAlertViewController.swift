//
//  LoginAlertView.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/06/08.
//

import UIKit

final class LoginAlertViewController: UIViewController {
    
    // MARK: - Properties
        
    private lazy var alertView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 2.5
        view.layer.cornerRadius = 10
        
        [cancelButton, iconImageView, guideLabel, kakaoLoginButton].forEach(view.addSubview)
        return view
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    private let iconImageView: UIImageView = {
        let image = UIImage(named: "selectedBluePoint")?.scalePreservingAspectRatio(targetSize: CGSize(width: 60,
                                                                                                       height: 60))
        let iv = UIImageView()
        iv.image = image
        return iv
    }()

    private let guideLabel: UILabel = {
        let label = UILabel()
        label.text = "로그인을 하면 별점, 즐겨찾기 등 \n더 많은 기능을 이용할 수 있습니다."
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .lightGray
        label.textAlignment = .center
        return label
    }()
    
    private let kakaoLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.backgroundColor = #colorLiteral(red: 0.9843717217, green: 0.8225817084, blue: 0.1790408194, alpha: 1)
        
        button.setTitle("카카오계정으로 로그인", for: .normal)
        button.tintColor = .black
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .light)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 0.3)
        view.addSubview(alertView)
        alertView.setDimensions(height: view.frame.height / 3, width: view.frame.height / 3)
        alertView.centerInSuperview()

        configureUI()
        setButtonActions()
    }

    
    // MARK: - Actions
    
    @objc private func cancelButtonTapped() {
        self.dismiss(animated: true)
    }
    
    @objc private func kakaoLoginButtonTapped() {
        // 로그인 된 경우 -> 로그아웃
        // 로그인 안 된 경우 -> 로그인
        
        print("카카오 로그인 구현하기")
    }
    
    // MARK: - Helpers
    private func configureUI() {
        cancelButton.anchor(top: alertView.topAnchor, right: alertView.rightAnchor, paddingTop: 12, paddingRight: 15)
        
        iconImageView.anchor(top: alertView.topAnchor, paddingTop: 25)
        iconImageView.centerX(inView: alertView)
        
        guideLabel.anchor(top: iconImageView.bottomAnchor, paddingTop: 17)
        guideLabel.centerX(inView: alertView)
        
        kakaoLoginButton.centerX(inView: alertView)
        kakaoLoginButton.anchor(top: guideLabel.bottomAnchor, paddingTop: 20)
        kakaoLoginButton.setDimensions(height: 50,
                                       width: (view.frame.width / 2) + 30)
    }
    
    private func setButtonActions() {
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        kakaoLoginButton.addTarget(self, action: #selector(kakaoLoginButtonTapped), for: .touchUpInside)
    }
    
}
