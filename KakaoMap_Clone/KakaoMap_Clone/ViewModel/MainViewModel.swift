//
//  MainViewModel.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/24.
//

import Foundation

class MainViewModel {
    
    // MARK: - Stored Properties

    var longtitude: Double?
    var latitude: Double?
    
    // MARK: - Computed Properties

    var openMenu = { }
    
    var closeMenu = { }
    
    // MARK: - Methods
    
    /// 현재 위치로 주소 정보 받기
    func getAddressSearchResult(lon: Double, lat: Double, completion: @escaping (String) -> Void) {
        let stringLon = String(lon)
        let stringLat = String(lat)
        HttpClient.shared.getLocationAddress(lon: stringLon, lat: stringLat) { result in
            guard let document = result.documents?.first,
                  let currentAddress = document.addressName else {
                print("SearchVM - document 없음")
                return
            }
            completion(currentAddress)
        }
    }
}
