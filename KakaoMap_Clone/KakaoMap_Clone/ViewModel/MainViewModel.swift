//
//  MainViewModel.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/24.
//

import Foundation

class MainViewModel {
    
    // MARK: - Stored Properties
    
    private var longtitude: Double?
    private var latitude: Double?
    
    private var mapAddress: String?
    
    // MARK: - Computed Properties
    
    var openMenu = { }
    
    var closeMenu = { }
    
    /// 지도 위치 주소 데이터로 UI 세팅하기
    var setAddress: (String) -> Void = { _ in }
    
    // MARK: - Methods
    
    /// 지도 위치로 주소 정보 받기
    func getAddressSearchResult(lon: Double, lat: Double) {
        longtitude = lon
        latitude = lat
        
        let stringLon = String(lon)
        let stringLat = String(lat)
        HttpClient.shared.getLocationAddress(lon: stringLon, lat: stringLat) { [weak self] result in
            guard let document = result.documents?.first,
                  let address = document.addressName else {
                print("SearchVM - document 없음")
                return
            }
            self?.setAddress(address)
            self?.mapAddress = address
        }
    }
    
    /// 검색 탭 누르면 실행 - SearchVC를 띄워서 검색 시작할 수 있도록 하기
    func getSearchVC(currentLon: Double, currentLat: Double) -> SearchViewController? {
        guard let mapLon = longtitude,
              let mapLat = latitude,
              let mapAddress = mapAddress else { return nil }
        let searchVM = SearchViewModel(mapLon: String(mapLon),
                                       mapLat: String(mapLat),
                                       currentLon: currentLon,
                                       currentLat: currentLat,
                                       mapAddress: mapAddress)
        let searchVC = SearchViewController()
        searchVC.viewModel = searchVM
        return searchVC
    }
}
