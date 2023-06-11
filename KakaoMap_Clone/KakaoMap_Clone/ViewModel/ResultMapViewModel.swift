//
//  ResultMapViewModel.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/30.
//

import Foundation

class ResultMapViewModel: MapDataType {
    
    var keyword: String?
    
    var mapCoordinate: Coordinate
    private let currentCoordinate: Coordinate = UserDefaultsManager.shared.currentCoordinate
    
    var mapAddress: CurrentAddressDocument
    
    var searchResults: [KeywordDocument]
    var searchHistories: [SearchHistory]?
    
    private var selectedPlace: KeywordDocument? {
        didSet {
            setTargetPlaceData()
        }
    }
    
    var targetPlaceData: CertainPlaceData? {
        didSet {
            needToSetTargetPlaceUI()
        }
    }
    
    private var page: Int = 1
    private var loading: Bool = false
    
    var isMapBasedData: Bool = true
    var isAccuracyAlignment: Bool = true
    
    var headerFooterIsHidden = false {
        didSet {
            if !headerFooterIsHidden {
                needToHideHeaderAndFooterView()
            } else {
                needToShowHeaderAndFooterView()
            }
        }
    }
    
// MARK: - Computed Properties

    var targetPlace: KeywordDocument? {
        get {
            return selectedPlace
        }
        set {
            selectedPlace = newValue
        }
    }
    /// header footer view 화면에 보이도록 애니메이션 효과 주기
    var needToShowHeaderAndFooterView = { }
    
    /// header footer view 화면에 보이지 않도록 애니메이션 효과 주기
    var needToHideHeaderAndFooterView = { }
    
    var needToSetTargetPlaceUI = { }
    
    var startFetchingData = { }
    var finishFetchingData = { }
    
    var showNoPhoneNumberToast = { }
    
// MARK: - Initializer
    
    init(mapData: MapDataType) {
        keyword = mapData.keyword
        mapCoordinate = mapData.mapCoordinate
        mapAddress = mapData.mapAddress
        searchResults = mapData.searchResults
        searchHistories = mapData.searchHistories
    }
    
    /// id에 해당되는 장소를 return
    func filterResults(with id: Int) -> KeywordDocument {
        let targetPlace = searchResults.filter({ $0.id == String(id) }).first
        self.targetPlace = targetPlace
        return targetPlace!
    }
    
    /// 현재 위치에서 해당 장소로 이동하는 경로 알려주기
    func getDirection(completion: @escaping ([Guide]) -> Void) {
        guard let targetPlace = targetPlace,
              let destinationLon = targetPlace.x,
              let destinationLat = targetPlace.y,
              let lon = Double(destinationLon),
              let lat = Double(destinationLat) else { return }
        
        HttpClient.shared.getDirection(startPoint: currentCoordinate,
                                       destination: Coordinate(longtitude: lon,
                                                               latitude: lat)) { result in
            guard let routes = result.routes else {
                print("자동차 경로 없음")
                return
            }
            guard let sections = routes[0].sections,
                  let guides = sections[0].guides else { return }
                completion(guides)
        }
    }
 
    /// 선택된 장소에 해당하는 전화번호에 전화하기
    func callToTargetPlace() {
        guard let phoneNumber = targetPlace?.phone,
              phoneNumber.map({ $0 }).count > 9 else {
            // 전화번호 없음을 알리는 토스트 메세지 띄우기
            showNoPhoneNumberToast()
            print("전화번호 없음")
            return
        }
        if let phoneCallURL = URL(string: "tel://\(phoneNumber)") {
        print("전화번호: \(phoneNumber)")
          let application:UIApplication = UIApplication.shared
          if (application.canOpenURL(phoneCallURL)) {
              application.open(phoneCallURL, options: [:], completionHandler: nil)
          }
        }
    }
    
    /// 해당되는 장소에 대한 세부 데이터 받아오기 (별점, 리뷰, 사진 등)
    private func setTargetPlaceData() {
        guard let placeId = self.targetPlace?.id else { return }
        
        self.startFetchingData()
        
        HttpClient.shared.getReviewForCertainPlace(placeCode: placeId) { [weak self] placeData in
            self?.targetPlaceData = placeData
            self?.finishFetchingData()
        }
    }
}
