//
//  CustomAlignmentAlertViewController.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/24.
//

import UIKit

class CustomAlignmentAlertViewController: UIViewController {
    
    private var alertView: CustomAlignmentAlertView?
    
    // MARK: - Lifecycle
    
    init(isCenterAlignment: Bool) {
        super.init(nibName: nil, bundle: nil)
        alertView = CustomAlignmentAlertView(isCenterAlignment: isCenterAlignment)
    }
    
    override func loadView() {
        view = alertView!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setActions()
    }
    
    // MARK: - Actions
    
    @objc private func firstButtonTapped() {
        alertView?.getFirstButton().tintColor = #colorLiteral(red: 0.03529411765, green: 0.5176470588, blue: 0.8901960784, alpha: 1)
        alertView?.getFirstButton().layer.borderColor = #colorLiteral(red: 0.03529411765, green: 0.5176470588, blue: 0.8901960784, alpha: 1)
        
        alertView?.getSecondButton().tintColor = .gray
        alertView?.getSecondButton().layer.borderColor = UIColor.gray.cgColor
        // 위치기준 변경 혹은 정렬 변경에 따라 SearchResultVC 업데이트 + self.dismiss
    }

    @objc private func secondButtonTapped() {
        alertView?.getSecondButton().tintColor = #colorLiteral(red: 0.03529411765, green: 0.5176470588, blue: 0.8901960784, alpha: 1)
        alertView?.getSecondButton().layer.borderColor = #colorLiteral(red: 0.03529411765, green: 0.5176470588, blue: 0.8901960784, alpha: 1)
        
        alertView?.getFirstButton().tintColor = .gray
        alertView?.getFirstButton().layer.borderColor = UIColor.gray.cgColor
        // 위치기준 변경 혹은 정렬 변경에 따라 SearchResultVC 업데이트 + self.dismiss
    }
    
    @objc private func cancelButtonTapped() {
        self.dismiss(animated: false)
    }
    
    // MARK: - Helpers
    
    func setActions() {
        alertView?.getFirstButton().addTarget(self, action: #selector(firstButtonTapped), for: .touchUpInside)
        alertView?.getSecondButton().addTarget(self, action: #selector(secondButtonTapped), for: .touchUpInside)
        alertView?.getCancelButton().addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
}
