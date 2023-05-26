//
//  CustomAlignmentAlertView.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/24.
//

import UIKit

class CustomAlignmentAlertView: UIView {
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        
        [mainLabel, cancelButton, buttonStackView].forEach { view.addSubview($0) }
        return view
    }()
    
    private let mainLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = .black.withAlphaComponent(0.8)
        return label
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .black.withAlphaComponent(0.8)
        button.setDimensions(height: 20, width: 20)
        return button
    }()
    
    private let firstButton: UIButton = {
        let button = UIButton(type: .system)
        button.clipsToBounds = true
        button.tintColor = .gray
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.gray.cgColor
        return button
    }()
    
    private let secondButton: UIButton = {
        let button = UIButton(type: .system)
        button.clipsToBounds = true
        button.tintColor = .gray
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.gray.cgColor
        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [firstButton, secondButton])
        stack.spacing = 10
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()
    
    // MARK: - Lifecycle
    
    init(isCenterAlignment: Bool, firstButtonTapped: Bool) {
        super.init(frame: .zero)
        backgroundColor = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 0.3)
        
        setAutolayout()
        configureUI(isCenterAlignment: isCenterAlignment, firstButtonTapped: firstButtonTapped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func setAutolayout() {
        addSubview(containerView)
        containerView.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        containerView.heightAnchor.constraint(equalToConstant: 170).isActive = true

        mainLabel.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, paddingTop: 25, paddingLeft: 14)
        
        cancelButton.anchor(top: containerView.topAnchor, right: containerView.rightAnchor, paddingTop: 12, paddingRight: 12)
        
        buttonStackView.setDimensions(height: 40, width: 350)
        buttonStackView.centerX(inView: containerView)
        buttonStackView.centerY(inView: containerView)
    }
    
    func configureUI(isCenterAlignment: Bool, firstButtonTapped: Bool) {
        if isCenterAlignment {
            mainLabel.text = "중심점"
            firstButton.setTitle("내위치중심", for: .normal)
            secondButton.setTitle("지도중심", for: .normal)
        } else {
            mainLabel.text = "정렬 옵션"
            firstButton.setTitle("정확도순", for: .normal)
            secondButton.setTitle("거리순", for: .normal)
        }
        
        if !firstButtonTapped {
            secondButton.layer.borderColor = #colorLiteral(red: 0.03529411765, green: 0.5176470588, blue: 0.8901960784, alpha: 1)
            secondButton.tintColor = #colorLiteral(red: 0.03529411765, green: 0.5176470588, blue: 0.8901960784, alpha: 1)
        } else {
            firstButton.layer.borderColor = #colorLiteral(red: 0.03529411765, green: 0.5176470588, blue: 0.8901960784, alpha: 1)
            firstButton.tintColor = #colorLiteral(red: 0.03529411765, green: 0.5176470588, blue: 0.8901960784, alpha: 1)
        }
    }
    
    func getFirstButton() -> UIButton {
        return firstButton
    }
    
    func getSecondButton() -> UIButton {
        return secondButton
    }
    
    func getCancelButton() -> UIButton {
        return cancelButton
    }
    
}
