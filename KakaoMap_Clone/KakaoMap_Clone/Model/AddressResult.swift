//
//  SearchResult.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/23.
//

import Foundation

// MARK: - CurrentAddressResult
struct CurrentAddressResult: Codable {
    let documents: [CurrentAddressDocument]?
}

// MARK: - Document
struct CurrentAddressDocument: Codable {
    let regionType, code, addressName: String?
    let x, y: Double?

    enum CodingKeys: String, CodingKey {
        case regionType = "region_type"
        case code
        case addressName = "address_name"
        case x, y
    }
}

