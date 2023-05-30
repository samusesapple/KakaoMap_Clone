//
//  SearchResultTableViewCell.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/24.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    private let placeNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black.withAlphaComponent(0.8)
        label.text = "카페 건"
        label.font = UIFont.systemFont(ofSize: 16.5)
        label.textAlignment = .left
        return label
    }()
    
    private let placeCategoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray.withAlphaComponent(0.8)
        label.text = "카테고리"
        label.font = UIFont.systemFont(ofSize: 12.5)
        label.textAlignment = .left
        return label
    }()
    
    private let reviewView = ReviewStarView()
    
    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .darkGray
        label.text = "1.6km"
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .darkGray
        label.text = "인천 중구 하늘달빛로2번길 8 씨사이드파크"
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var hStackView: UIStackView = {
        let middleView = UIView()
        middleView.setDimensions(height: 13, width: 1)
        middleView.backgroundColor = .lightGray.withAlphaComponent(0.5)
        
        let stack = UIStackView(arrangedSubviews: [distanceLabel, middleView, addressLabel])
        stack.alignment = .leading
        stack.spacing = 6
        stack.distribution = .equalSpacing
        return stack
    }()
    
//    private let placeImageView: UIImageView = {
//       let iv = UIImageView()
//        iv.layer.cornerRadius = 5
//        iv.clipsToBounds = true
//        iv.backgroundColor = .blue
//        return iv
//    }()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .white
        setAutolayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    // MARK: - Helpers
    
    private func setAutolayout() {
        contentView.addSubview(placeNameLabel)
        placeNameLabel.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, paddingTop: 18, paddingLeft: 17)
        
        contentView.addSubview(placeCategoryLabel)
        placeCategoryLabel.anchor(left: placeNameLabel.rightAnchor, bottom: placeNameLabel.bottomAnchor, paddingLeft: 6)
        
        contentView.addSubview(reviewView)
        reviewView.setDimensions(height: 13, width: contentView.frame.width / 2)
        reviewView.anchor(top: placeNameLabel.bottomAnchor, left: contentView.leftAnchor, paddingTop: 10, paddingLeft: 17)
        
//        contentView.addSubview(placeImageView)
//        placeImageView.setDimensions(height: 85, width: 85)
//        placeImageView.anchor(bottom: contentView.bottomAnchor, right: contentView.rightAnchor, paddingBottom: 18, paddingRight: 17)
        
        contentView.addSubview(hStackView)
        hStackView.anchor(top: reviewView.bottomAnchor, left: contentView.leftAnchor, paddingTop: 8, paddingLeft: 17)
    }
    
    func configureUIwithData(data: KeywordDocument) {
        placeNameLabel.text = data.placeName
        addressLabel.text = data.roadAddressName
        placeCategoryLabel.text = data.categoryGroupName
        
        guard let distance = data.distance else { return }
        distanceLabel.text = MeasureFormatter.measureDistance(distance: distance)
    }
}
