//
//  MenuViewController.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/30.
//

import UIKit

protocol MenuViewControllerDelegate: AnyObject {
    func needToCloseMenuView()
}

class MenuViewController: UIViewController {

    // MARK: - Properties
    
    private lazy var menuView = MenuView(frame: CGRect(x: 0,
                                          y: 0,
                                          width: (view.frame.width / 3) * 2,
                                          height: view.frame.height))
    
    weak var delegate: MenuViewControllerDelegate?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        view.addSubview(menuView)
        setMenuViewButtonActions()
        
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(menuViewStartedSwiping)))
    }
    
    // MARK: - Actions
    
    @objc private func reviewButtonTapped() {
        print("작성한 리뷰 리스트 띄우기")
    }
    
    @objc private func favoritesButtonTapped() {
        print("즐겨찾기한 장소 리스트 보여주기")
    }
    
    @objc private func loginButtonTapped() {
        print("로그인 상태 화면 설정에 띄우기")
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
