//
//  MainViewModel.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/24.
//

import Foundation

final class MainViewModel {

    // MARK: - Stored Properties
    
    private var mapCoordinate: Coordinate?
    
    private var menuOpened: Bool = false {
        didSet {
            self.menuOpened == true ? self.openMenu() : self.closeMenu()
        }
    }

    private var mapAddress: CurrentAddressDocument? {
        didSet {
            // 지도 주소 값 바뀔 때마다 mainVC UI 세팅하기
            setAddress(mapAddress!.addressName!)
        }
    }
    
    // MARK: - Computed Properties
    
    var openMenu = { }
    
    var closeMenu = { }
    
    /// 지도 위치 주소 데이터로 UI 세팅하기
    var setAddress: (String) -> Void = { _ in }
    
    var needToOpenMenu: Bool {
        get {
            return menuOpened
        }
        set {
            self.menuOpened = newValue
        }
    }
    
    // MARK: - Methods
    
    /// 지도 위치로 주소 정보 받기
    func getAddressDetailResult(lon: Double, lat: Double) {
        let mapCoordinate = Coordinate(longtitude: lon,
                                    latitude: lat)
        self.mapCoordinate = mapCoordinate

        HttpClient.shared.getLocationAddress(coordinate: mapCoordinate) { [weak self] result in
            guard let document = result.documents?.first else {
                print("SearchVM - document 없음")
                return
            }
            // 지도 주소 변수 초기화하기
            self?.mapAddress = document
        }
    }
    
    /// 검색 탭 누르면 실행 - SearchVC를 띄워서 검색 시작할 수 있도록 하기
    func getSearchVC(currentLon: Double, currentLat: Double) -> SearchViewController? {
        setCurrentCoordinate(lon: currentLon, lat: currentLat)
        
        guard let mapCoordinate = mapCoordinate,
              let mapAddress = mapAddress else { return nil }
        let searchVM = SearchViewModel(mapCoordinate: mapCoordinate, // currentCoordinate 대신에 UserDefaultsManager에 저장하기
                                       mapAddress: mapAddress)
        let searchVC = SearchViewController()
        searchVC.viewModel = searchVM
        return searchVC
    }
    
    private func setCurrentCoordinate(lon: Double, lat: Double) {
        let coordinate = Coordinate(longtitude: lon,
                                    latitude: lat)
        UserDefaultsManager.shared.setCurrentCoordinate(coordinate: coordinate)
    }
}
