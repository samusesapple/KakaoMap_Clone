//
//  DistanceAddressView.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/06/14.
//

import Foundation

class DistanceAddressStackView: UIStackView {
    
    let distanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .darkGray
        return label
    }()
    
     let addressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .darkGray
        label.numberOfLines = 1
        return label
    }()
  
    private let middleView: UIView = {
       let view = UIView()
        view.setDimensions(height: 13, width: 1)
        view.backgroundColor = .lightGray.withAlphaComponent(0.5)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        [distanceLabel, middleView, addressLabel, UIView()].forEach(addArrangedSubview)
        self.alignment = .leading
        self.spacing = 6
        self.distribution = .fill
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
