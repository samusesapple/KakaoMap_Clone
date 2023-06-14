//
//  MenuOptionsButton.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/06/04.
//

import UIKit

final class MenuOptionsButton: UIButton {

    init(text: String, image: UIImage?) {
        super.init(frame: .zero)
        self.setImage(image?.resizeImage(targetSize: CGSize(width: 30, height: 30)), for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        self.setTitle("   \(text)", for: .normal)
        self.setTitleColor(.black, for: .normal)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
