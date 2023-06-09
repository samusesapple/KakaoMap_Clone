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
//        ["userName": name,
//                 "userEmail": userEmail,
//                 "profileImageURL": profileImageURL
//                ] as [String : Any]
        guard let userInfo = notification.object as? [String: Any],
              let name = userInfo["userName"] as? String,
              let profileImageURL = userInfo["profileImageURL"] as? URL,
              let isKakaoLogin = userInfo["isKakaoLogin"] as? Bool else { return }
        if isKakaoLogin {
            print("MenuVC 옵저버 - 카카오 로그인 감지 완료")
        }
        menuView.userLoginButton.setTitle("로그아웃", for: .normal)
        menuView.configureUIwithUserData(imageURL: profileImageURL, name: name)
    }
    
    @objc private func userDidLogout(_ notification: Notification) {
        menuView.userLoginButton.setTitle("로그인", for: .normal)
        menuView.configureUIwithUserData(imageURL: nil, name: nil)
    }
    
    @objc private func reviewButtonTapped() {
        print("작성한 리뷰 리스트 띄우기")
    }
    
    @objc private func favoritesButtonTapped() {
        print("즐겨찾기한 장소 리스트 보여주기")
    }
    
    @objc private func loginButtonTapped() {
        // 로그인 상태인 경우, 로그아웃
        guard menuView.userLoginButton.titleLabel?.text == "로그인" else {
            viewModel.logout()
            return
        }
        let alertVC = LoginAlertViewController()
        alertVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        alertVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(alertVC, animated: true)
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
    
    private func setMenuViewButtonActions() {
        menuView.checkReviewButton.addTarget(self, action: #selector(reviewButtonTapped), for: .touchUpInside)
        menuView.favoritePlaceButton.addTarget(self, action: #selector(favoritesButtonTapped), for: .touchUpInside)
        menuView.userLoginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    

}
