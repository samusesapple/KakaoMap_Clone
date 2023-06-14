//
//  SearchResultTableViewCell.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/24.
//

import UIKit
import SDWebImage

class SearchResultTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    private let placeNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black.withAlphaComponent(0.8)
        label.font = UIFont.systemFont(ofSize: 16.5)
        label.textAlignment = .left
        return label
    }()
    
    private let placeCategoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray.withAlphaComponent(0.8)
        label.font = UIFont.systemFont(ofSize: 12.5)
        label.textAlignment = .left
        return label
    }()
    
    private let reviewView = ReviewStarView()
    
    private let distanceAddressStackView = DistanceAddressStackView()
    
//    private let distanceLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 13)
//        label.textColor = .darkGray
//        return label
//    }()
//    
//    private let addressLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 13)
//        label.textColor = .darkGray
//        label.numberOfLines = 1
//        return label
//    }()
//    
//    private lazy var hStackView: UIStackView = {
//        let middleView = UIView()
//        middleView.setDimensions(height: 13, width: 1)
//        middleView.backgroundColor = .lightGray.withAlphaComponent(0.5)
//        
//        let stack = UIStackView(arrangedSubviews: [distanceLabel, middleView, addressLabel])
//        stack.alignment = .leading
//        stack.spacing = 6
//        stack.distribution = .fill
//        return stack
//    }()
    
    private let placeImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "loadingImagePlaceholder")
        iv.layer.cornerRadius = 5
        iv.clipsToBounds = true
        return iv
    }()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .white
        setAutolayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        placeImageView.image = UIImage(named: "imagePlaceholder")
        placeNameLabel.text = nil
        placeCategoryLabel.text = nil
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
        
        contentView.addSubview(placeImageView)
        placeImageView.setDimensions(height: 85, width: 85)
        placeImageView.anchor(bottom: contentView.bottomAnchor, right: contentView.rightAnchor, paddingBottom: 18, paddingRight: 17)
        
        contentView.addSubview(distanceAddressStackView)
        distanceAddressStackView.anchor(top: reviewView.bottomAnchor, left: contentView.leftAnchor,right: placeImageView.leftAnchor, paddingTop: 8, paddingLeft: 17, paddingRight: 10)
        }
    
    func configureUIwithData(data: KeywordDocument) {
        placeNameLabel.text = data.placeName
        distanceAddressStackView.addressLabel.text = data.roadAddressName
        placeCategoryLabel.text = data.categoryGroupName
        
        guard let distance = data.distance else { return }
        distanceAddressStackView.distanceLabel.text = MeasureFormatter.measureDistance(distance: distance)
    }
    
    func setPlaceReviewData(data: TargetPlaceDetail) {
        guard let reviewCount = data.comment?.scorecnt,
              let totalScore = data.comment?.scoresum,
              let placeAddress = distanceAddressStackView.addressLabel.text else {
            guard let reviewNotBlocked = data.comment?.reviewWriteBlocked else {
                reviewView.configureBannedReviewUI()
                guard let imageURL = data.basicInfo?.mainphotourl else {
                    placeImageView.image = UIImage(named: "imagePlaceholder")
                    return
                }
                placeImageView.sd_setImage(with: URL(string: imageURL))
                return
            }
            if reviewNotBlocked == "NONE" {
                reviewView.configureNoReviewExistUI()
                guard let imageURL = data.basicInfo?.mainphotourl else {
                    placeImageView.image = UIImage(named: "imagePlaceholder")
                    return
                }
                placeImageView.sd_setImage(with: URL(string: imageURL))
            }
//            if data.comment!.reviewWriteBlocked == "NONE" {
//                reviewView.configureNoReviewExistUI()
//            } else {
//                reviewView.configureBannedReviewUI()
//            }
            return
        }
        // 평균 별점
        let averageReviewPoint = (round((Double(totalScore) / Double(reviewCount)) * 10) / 10)
        // 평균 별점, 썸네일 이미지 세팅
        reviewView.configureUI(averagePoint: averageReviewPoint, reviewCount: reviewCount)
        // 상세 주소 있는 경우 세팅
        if let detailAddress = data.basicInfo?.address?.addrdetail {
            distanceAddressStackView.addressLabel.text = placeAddress + " \(detailAddress)"
        }
        // 이미지 있는 경우 세팅
        guard let imageURL = data.basicInfo?.mainphotourl else {
            placeImageView.image = UIImage(named: "imagePlaceholder")
            return
        }
        placeImageView.sd_setImage(with: URL(string: imageURL))
    }
}
