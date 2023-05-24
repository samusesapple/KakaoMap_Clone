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
        label.text = "3.5"
        label.textColor = #colorLiteral(red: 0.8392156863, green: 0.1882352941, blue: 0.1921568627, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    let reviewStarts: UILabel = {
        let label = UILabel()
        label.text = "★★★☆☆"
        label.textColor = #colorLiteral(red: 0.8392156863, green: 0.1882352941, blue: 0.1921568627, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    let totalReviewCountLabel: UILabel = {
        let label = UILabel()
        label.text = "(39)"
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
    
    func setAutolayout() {
        addSubview(reviewAveragePointLabel)
        reviewAveragePointLabel.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor)
        
        addSubview(reviewStarts)
        reviewStarts.anchor(top: self.topAnchor, left: reviewAveragePointLabel.rightAnchor, bottom: self.bottomAnchor, paddingLeft: 4)
        
        addSubview(totalReviewCountLabel)
        totalReviewCountLabel.anchor(top: self.topAnchor, left: reviewStarts.rightAnchor, bottom: self.bottomAnchor, paddingLeft: 4)
    }
}
