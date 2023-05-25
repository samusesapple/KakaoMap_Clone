//
//  KeywordResult.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/23.
//

import Foundation
// MARK: - KeywordResult
struct KeywordResult: Codable {
    let documents: [KeywordDocument]?
    let meta: Meta?
}

// MARK: - Document
struct KeywordDocument: Codable {
    let addressName, categoryGroupCode, categoryGroupName: String?
    let distance, id, phone, placeName: String?
    let placeURL: String?
    let roadAddressName, x, y: String?

    enum CodingKeys: String, CodingKey {
        case addressName = "address_name"
        case categoryGroupCode = "category_group_code"
        case categoryGroupName = "category_group_name"
        case distance, id, phone
        case placeName = "place_name"
        case placeURL = "place_url"
        case roadAddressName = "road_address_name"
        case x, y
    }
}

// MARK: - Meta
struct Meta: Codable {
    let isEnd: Bool?
    let pageableCount: Int?
    let totalCount: Int?

    enum CodingKeys: String, CodingKey {
        case isEnd = "is_end"
        case pageableCount = "pageable_count"
        case totalCount = "total_count"
    }
}
