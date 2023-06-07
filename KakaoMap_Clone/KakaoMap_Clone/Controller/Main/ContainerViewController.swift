//
//  ContainerViewController.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/06/07.
//

import UIKit

final class ContainerViewController: UIViewController {
    
    private enum MenuState {
        case opened
        case closed
    }
    
    private var menuState: MenuState = .closed
    
    private let mainVC = MainViewController()
    private let menuVC = MenuViewController()
    private var navVC: UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addChildVC()
    }
    
    
    private func addChildVC() {
        addChild(menuVC)
        view.addSubview(menuVC.view)
        menuVC.didMove(toParent: self)
        
        mainVC.delegate = self
        let navVC = UINavigationController(rootViewController: mainVC)
        addChild(navVC)
        view.addSubview(navVC.view)
        navVC.didMove(toParent: self)
        self.navVC = navVC
    }
    
    
}

extension ContainerViewController: MainViewControllerDelegate {
    func didTappedMenuButton() {
        switch menuState {
        case .closed:
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
                self.mainVC.view.transform = CGAffineTransform(translationX: (self.mainVC.view.frame.width / 3) * 2, y: 0)
            } completion: { [weak self] done in
                if done {
                    self?.menuState = .opened
                }
            }
            
        case .opened:
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
                self.mainVC.view.transform = CGAffineTransform(translationX: 0, y: 0)
            } completion: { done in
                if done {
                    self.menuState = .closed
                }
            }
        }
    }
}
