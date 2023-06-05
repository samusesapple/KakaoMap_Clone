//
//  MenuViewController.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/30.
//

import UIKit

class MenuViewController: UIViewController {

    // MARK: - Properties
    
    private lazy var menuView = MenuView(frame: CGRect(x: 0,
                                          y: 0,
                                          width: view.frame.width,
                                          height: view.frame.height))
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        view.addSubview(menuView)
    }

    // MARK: - Actions
    

    // MARK: - Helpers

}
