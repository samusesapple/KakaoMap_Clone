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
        mainVC.delegate = self
        let navVC = UINavigationController(rootViewController: mainVC)
        addChild(navVC)
        view.addSubview(navVC.view)
        navVC.didMove(toParent: self)
        
        // mainVC 위에 menuVC 쌓기
        mainVC.addChild(menuVC)
        mainVC.view.addSubview(menuVC.view)
        menuVC.didMove(toParent: self)
        // menuVC 숨기기
        menuVC.view.transform = CGAffineTransform(translationX: -menuVC.view.frame.width, y: 0)
        
        self.navVC = navVC
    }
    
    
}

extension ContainerViewController: MainViewControllerDelegate {
    func didTappedMenuButton() {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) { [weak self] in
                self?.menuVC.view.transform = CGAffineTransform(translationX: 0, y: 0)
            } completion: { [weak self] done in
                if done {
                    self?.menuState = .opened
                    self?.menuVC.view.backgroundColor = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 0.7)
                }
            }
        }
}
