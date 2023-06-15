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
    var distance: String = ""
    
    init(dictionary: [String: Any]) {
        self.placeName = dictionary["placeName"] as! String
        self.placeID = dictionary["placeID"] as! String
        self.address = dictionary["address"] as! String
        
        let coordinate = dictionary["coordinate"] as! [String: Any]
        let longtitude = coordinate["longtitude"] as! String
        let latitude = coordinate["latitude"] as! String
        self.coordinate = Coordinate(longtitude: Double(longtitude) ?? 0, latitude: Double(latitude) ?? 0)
        
//        getDistance(name: self.placeName, id: self.placeID)
    }
//
    init(data: FavoritePlace, distance: String) {
        self.placeName = data.placeName
        self.placeID = data.placeID
        self.address = data.address
        self.coordinate = data.coordinate
        self.distance = distance
    }
    
//    private mutating func getDistance(name: String, id: String) {
//        HttpClient.shared.searchKeyword(with: name,
//                                        coordinate: UserDefaultsManager.shared.currentCoordinate,
//                                        page: 1) { [self] result in
//            guard let result = result,
//                  let docs = result.documents else { return }
//            let target = docs.filter { $0.id == id }[0]
//
//            guard let distance = target.distance else { return }
//            self.distance = distance
//        }
//    }
}
