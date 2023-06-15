//
//  FavoriteViewTableViewCell.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/06/14.
//

import UIKit

class FavoriteViewTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    var viewModel: FavoriteViewModel!
    
    var id: String?
    
    let starButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "star.fill")?
            .withRenderingMode(.alwaysTemplate)
            .resizeImage(targetSize: CGSize(width: 30, height: 30)),
                        for: .normal)
        button.tintColor = #colorLiteral(red: 0.9591769576, green: 0.8024938703, blue: 0.04654744267, alpha: 1)
        return button
    }()
    
    private let placeNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.tintColor = .black
        return label
    }()
    
    private let distanceAddressStackView = DistanceAddressStackView()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.backgroundColor = .white
        setAutolayout()
        
        starButton.addTarget(self,
                                  action: #selector(removeFavorite),
                                  for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc private func removeFavorite() {
        guard let id = id else {
            print("place id 없음")
            return
        }
        starButton.setImage(UIImage(systemName: "star")?
            .withRenderingMode(.alwaysTemplate)
            .resizeImage(targetSize: CGSize(width: 30,
                                            height: 30)),
                        for: .normal)
        starButton.tintColor = .gray
        viewModel.removeFavorite(id: id)
    }
    
    // MARK: - Helpers

    private func setAutolayout() {
        self.contentView.addSubview(starButton)
        starButton.anchor(top: contentView.topAnchor,
                          left: contentView.leftAnchor,
                          paddingTop: 14,
                          paddingLeft: 12)
    
        
        self.contentView.addSubview(placeNameLabel)
        placeNameLabel.anchor(top: starButton.topAnchor,
                              left: starButton.rightAnchor,
                              paddingLeft: 12)
        
        self.contentView.addSubview(distanceAddressStackView)
        distanceAddressStackView.anchor(top: placeNameLabel.bottomAnchor,
                                        left: placeNameLabel.leftAnchor,
                                        right: contentView.rightAnchor,
                                        paddingTop: 6,
                                        paddingRight: 12)
    }
    
    func configureUIwithData(_ data: FavoritePlace) {
        placeNameLabel.text = data.placeName
        distanceAddressStackView.addressLabel.text = data.address
//        distanceAddressStackView.distanceLabel.text = MeasureFormatter.measureDistance(distance: distance)
        self.id = data.placeID
    }
}
