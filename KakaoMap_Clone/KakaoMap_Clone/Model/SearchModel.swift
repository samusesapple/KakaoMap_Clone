//
//  SearchOption.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/30.
//

import Foundation

struct SearchOption {
    var icon: UIImage
    var title: String
}

struct SearchHistory: Equatable {
    var type: UIImage
    var searchText: String
    var address: String?
}
