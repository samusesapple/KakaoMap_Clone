//
//  FavoritePlace.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/06/11.
//

import Foundation

struct FavoritePlace {
    let placeName: String
    let placeID: String
    let address: String
    let coordinate: Coordinate
    
    init(dictionary: [String: Any]) {
        self.placeName = dictionary["placeName"] as! String
        self.placeID = dictionary["placeID"] as! String
        self.address = dictionary["address"] as! String
        
        let coordinate = dictionary["coordinate"] as! [String: Any]
        let longtitude = coordinate["longtitude"] as! String
        let latitude = coordinate["latitude"] as! String
        self.coordinate = Coordinate(longtitude: Double(longtitude) ?? 0, latitude: Double(latitude) ?? 0)
    }
}
