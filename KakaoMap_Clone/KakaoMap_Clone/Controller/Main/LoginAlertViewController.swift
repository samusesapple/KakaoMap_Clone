//
//  LoginAlertView.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/06/08.
//

import UIKit
import KakaoSDKUser
import FirebaseAuth
import JGProgressHUD

final class LoginAlertViewController: UIViewController {
    
    // MARK: - Properties
    
    private let progressIndicator = JGProgressHUD(style: .dark)
    
    private let viewModel: AuthViewModel = AuthViewModel()
    
    private let progressHud = JGProgressHUD(style: .dark)
    
    private lazy var alertView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 2.5
        view.layer.cornerRadius = 10
        
        [cancelButton, iconImageView, guideLabel, kakaoLoginButton, googleLoginButton, googleLoginButtonFooterLine].forEach(view.addSubview)
        return view
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    private let iconImageView: UIImageView = {
        let image = UIImage(named: "selectedBluePoint")?.resizeImage(targetSize: CGSize(width: 60, height: 60))
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
    
    private let googleLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("구글 이메일로 로그인", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .light)
        button.tintColor = .gray
        button.backgroundColor = .clear
        return button
    }()
    
    private lazy var googleLoginButtonFooterLine: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        return view
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
        
        viewModel.startLogin = { [weak self] in
            self?.progressHud.show(in: self!.alertView)
        }
        
        viewModel.finishedLogin = { [weak self] in
            self?.progressHud.dismiss()
            self?.cancelButtonTapped()
        }
    }
    
    // MARK: - Actions
    
    @objc private func cancelButtonTapped() {
        self.dismiss(animated: true)
    }
    
    @objc private func kakaoLoginButtonTapped() {
        // 로그인 안 된 경우 -> 로그인
        viewModel.kakaotalkLogin()
        print("카카오 로그인")
    }
    
    @objc private func googleLoginButtonTapped() {
        viewModel.googleLogin(presenter: self)
        print("구글 로그인")
    }
    
    // MARK: - Helpers
    private func configureUI() {
        cancelButton.anchor(top: alertView.topAnchor, right: alertView.rightAnchor, paddingTop: 12, paddingRight: 15)
        
        [iconImageView,
         guideLabel,
         kakaoLoginButton,
         googleLoginButton, googleLoginButtonFooterLine].forEach { $0.centerX(inView: alertView) }
        
        iconImageView.anchor(top: alertView.topAnchor, paddingTop: 25)
        
        guideLabel.anchor(top: iconImageView.bottomAnchor, paddingTop: 17)
        
        kakaoLoginButton.anchor(top: guideLabel.bottomAnchor, paddingTop: 20)
        kakaoLoginButton.setDimensions(height: 50,
                                       width: (view.frame.width / 2) + 30)
        
        googleLoginButton.anchor(top: kakaoLoginButton.bottomAnchor, paddingTop: 20)
        googleLoginButtonFooterLine.anchor(top: googleLoginButton.bottomAnchor, paddingTop: -8,
                                           width: 125, height: 1)
    }
    
    private func setButtonActions() {
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        kakaoLoginButton.addTarget(self, action: #selector(kakaoLoginButtonTapped), for: .touchUpInside)
        googleLoginButton.addTarget(self, action: #selector(googleLoginButtonTapped), for: .touchUpInside)
    }
    

}
