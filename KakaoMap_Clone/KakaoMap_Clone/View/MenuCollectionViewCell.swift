//
//  MenuCollectionViewCell.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/23.
//

import UIKit

class MenuCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    private let iconImageView: UIImageView = {
       let iv = UIImageView()
        iv.tintColor = .black
        iv.image = UIImage(systemName: "fork.knife")?.withRenderingMode(.alwaysTemplate)
        iv.setDimensions(height: 15, width: 15)
        return iv
    }()
    
    private let menuLabel: UILabel = {
        let label = UILabel()
        label.text = "메뉴"
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setAutolayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    private func setAutolayout() {
        contentView.addSubview(iconImageView)
        iconImageView.centerY(inView: contentView)
        iconImageView.anchor(left: contentView.leftAnchor, paddingLeft: 7)
        
        contentView.addSubview(menuLabel)
        menuLabel.centerY(inView: contentView)
        menuLabel.anchor(left: iconImageView.rightAnchor, right: contentView.rightAnchor,  paddingLeft: 5, paddingRight: 7)
    }
    
    func configureUI(with option: SearchOption) {
        iconImageView.image = option.icon
        menuLabel.text = option.title
    }
    
}
