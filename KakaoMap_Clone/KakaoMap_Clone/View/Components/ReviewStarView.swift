//
//  ReviewStarView.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/24.
//

import UIKit

class ReviewStarView: UIView {

    let reviewAveragePointLabel: UILabel = {
        let label = UILabel()
        label.textColor = #colorLiteral(red: 0.8392156863, green: 0.1882352941, blue: 0.1921568627, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    let reviewStars: UILabel = {
        let label = UILabel()
        label.text = "☆☆☆☆☆"
        label.textColor = #colorLiteral(red: 0.8392156863, green: 0.1882352941, blue: 0.1921568627, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    let totalReviewCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .lightGray
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
        addSubview(reviewAveragePointLabel)
        reviewAveragePointLabel.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor)
        
        addSubview(reviewStars)
        reviewStars.anchor(top: self.topAnchor, left: reviewAveragePointLabel.rightAnchor, bottom: self.bottomAnchor, paddingLeft: 4)
        
        addSubview(totalReviewCountLabel)
        totalReviewCountLabel.anchor(top: self.topAnchor, left: reviewStars.rightAnchor, bottom: self.bottomAnchor, paddingLeft: 4)
    }
    
    func configureUI(averagePoint: Double, reviewCount: Int) {
        reviewAveragePointLabel.text = String(averagePoint)
        totalReviewCountLabel.text = "(\(reviewCount))"
        guard let reviewStarText = reviewStars.text else { return }
        let averagePointInt = Int(exactly: averagePoint.rounded())
        
        var stringArray = reviewStarText.map { String($0) }
        
        guard let averagePointInt = averagePointInt else {
            configureNoReviewExistUI()
            return
        }
        
        for index in 0..<averagePointInt {
            stringArray[index] = "★"
        }
        
        let finalString = stringArray.joined()
        reviewStars.text = finalString
    }
    
    func configureBannedReviewUI() {
        reviewAveragePointLabel.textColor = .gray
        reviewAveragePointLabel.text = "리뷰 없음"
        totalReviewCountLabel.text = nil
        reviewStars.tintColor = .gray
        reviewStars.text = "후기 미제공 업체"
    }
    
    func configureNoReviewExistUI() {
        reviewAveragePointLabel.textColor = .gray
        reviewAveragePointLabel.text = "리뷰 없음"
        totalReviewCountLabel.text = ""
        reviewStars.text = nil
    }
}
