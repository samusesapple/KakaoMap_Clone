//
//  MenuViewController.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/30.
//

import UIKit
import KakaoSDKUser
import FirebaseAuth

protocol MenuViewControllerDelegate: AnyObject {
    func needToCloseMenuView()
    func needToPresent(viewController: FavoriteViewController)
}

final class MenuViewController: UIViewController {

    // MARK: - Properties
    
    private lazy var menuView = MenuView(frame: CGRect(x: 0,
                                          y: 0,
                                          width: (view.frame.width / 3) * 2,
                                          height: view.frame.height))
    
    private let viewModel: AuthViewModel = AuthViewModel()
    
    weak var delegate: MenuViewControllerDelegate?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        view.addSubview(menuView)
        setMenuViewButtonActions()
        
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(menuViewStartedSwiping)))
        
        checkUserLoginStatusAndConfigureUI()
        
        viewModel.showLoginToast = { [weak self] in
            self?.view.makeToast(message: "로그인이 필요합니다.")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 로그인 상태 구독
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(userDidLogIn),
                                               name: NotificationManager.loginNotificationName, object: nil)
        // 로그아웃 상태 구독
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(userDidLogout),
                                               name: NotificationManager.logoutNoficationName,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        
    }
    
    // MARK: - Actions
    
    // 유저 로그인 한 경우 view 세팅
    @objc private func userDidLogIn(_ notification: Notification) {
        print("userDidLogIn - MenuVC 감지함")
        guard let userInfo = notification.object as? [String: Any],
              let name = userInfo["userName"] as? String,
              let profileImageURL = userInfo["profileImageURL"] as? URL else { return }
            
        configureMenuUIwithKakaoLoginStatus(name: name, imageURL: profileImageURL)
    }
    
    @objc private func userDidLogout(_ notification: Notification) {
        menuView.userLoginButton.setTitle("   로그인", for: .normal)
        menuView.configureUIwithUserData(imageURL: nil, name: nil)
    }

    @objc private func favoritesButtonTapped() {
        viewModel.getFavoriteViewController { [weak self] favoriteVC in
            self?.delegate?.needToCloseMenuView()
            // mainVC에게 favoriteVC 보여주도록 시켜야함
            self?.delegate?.needToPresent(viewController: favoriteVC)
        }
    }
    
    @objc private func loginButtonTapped() {
        // 로그아웃 불가능한 경우, 로그인
        viewModel.logout {
            let alertVC = LoginAlertViewController()
            alertVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            alertVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            self.present(alertVC, animated: true)
        }
    }
    
    @objc private func menuViewStartedSwiping(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: nil)
        let degrees = translation.x
        
        DispatchQueue.main.async { [weak self] in
            if degrees < 0 {
                if abs(degrees) < 100 {
                    self?.view.backgroundColor = UIColor(red: 33/255,
                                                         green: 33/255,
                                                         blue: 33/255,
                                                         alpha: 0.8 - (abs(degrees) / 100))
                    self?.menuView.transform = CGAffineTransform(translationX: -(abs(degrees)), y: 0)
                    print(degrees)
                    return
                }
                else {
                    self?.view.removeGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                              action: #selector(self?.menuViewStartedSwiping)))
                    self?.delegate?.needToCloseMenuView()
                    print("메뉴 닫기")
                    return
                }
            }
            else {
                print("x좌표 + 되서 안됨")
                return
            }
        }
    }

    // MARK: - Helpers

    var menuContainer: MenuView {
        get {
            return menuView
        }
        set {
            return menuView = newValue
        }
    }
    
    /// 유저 로그인 여부 확인 후, 로그인 상태인 경우 UI 세팅
    private func checkUserLoginStatusAndConfigureUI() {
        guard let userData = viewModel.checkUserLoginStatus() else { return }
        
        print("유저 로그인 된 상태")
        configureMenuUIwithKakaoLoginStatus(name: userData.name, imageURL: userData.imageURL)
    }
    
    private func setMenuViewButtonActions() {
        menuView.favoritePlaceButton.addTarget(self, action: #selector(favoritesButtonTapped), for: .touchUpInside)
        menuView.userLoginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    
    /// 카카오 로그인 여부에 따라 다른 UI 세팅하기
    private func configureMenuUIwithKakaoLoginStatus(name: String, imageURL: URL) {
        guard let isKakaoLogin = UserDefaultsManager.shared.isKakaoLogin() else { return }
        if isKakaoLogin {
            print("카카오로 세팅")
            menuView.userLoginButton.setTitle("   카카오계정 로그아웃", for: .normal)
            menuView.configureUIwithUserData(imageURL: imageURL, name: name)
            return
        }
        print("구글로 세팅")
        menuView.userLoginButton.setTitle("   로그아웃", for: .normal)
        menuView.configureUIwithUserData(imageURL: imageURL, name: name)
    }
}
