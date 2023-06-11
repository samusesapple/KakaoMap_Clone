//
//  Coordinate.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/06/03.
//

import Foundation

struct Coordinate {
    var longtitude: Double
    var latitude: Double
    
    var stringLongtitude: String {
        return String(longtitude)
    }
    var stringLatitude: String {
        return String(latitude)
    }
    
    var totalCoordinate: String {
        return "\(longtitude),\(latitude)"
    }
    
}
