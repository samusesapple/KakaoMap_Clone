//
//  MenuOptionsButton.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/06/04.
//

import UIKit

class MenuOptionsButton: UIButton {

    init(text: String) {
        super.init(frame: .zero)
        
        self.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.setTitle(text, for: .normal)
        
        self.tintColor = .darkGray
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
