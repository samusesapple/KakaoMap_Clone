//
//  ResultMapViewModel.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/30.
//

import Foundation
import FirebaseAuth

final class ResultMapViewModel: MapDataType {
    
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
    
    var targetPlaceData: TargetPlaceDetail? {
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
    
    private var isFavoritePlace: Bool = false {
        didSet {
            configureButtonForFavoritePlace(isFavoritePlace)
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
    
    /// 유저의 로그인 상태
    var userLoginStatus: Bool = {
        guard let _ = Auth.auth().currentUser else {
            return false
        }
        return true
    }()
    
    /// header footer view 화면에 보이도록 애니메이션 효과 주기
    var needToShowHeaderAndFooterView = { }
    
    /// header footer view 화면에 보이지 않도록 애니메이션 효과 주기
    var needToHideHeaderAndFooterView = { }
    
    var needToSetTargetPlaceUI = { }
    
    var startFetchingData = { }
    var finishFetchingData = { }
    
    var showNoPhoneNumberToast = { }
        
    /// 해당되는 장소가 즐겨찾기에 위치한 장소라면 true, 아니라면 false를 리턴하는 클로저
    var configureButtonForFavoritePlace: (Bool) -> Void = { _ in }
    
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
        self.checkIfPlaceIsFavoritePlace(placeID: targetPlace!.id!) { [weak self] isFavoritePlace in
            self?.isFavoritePlace = isFavoritePlace
        }
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
    
    /// 즐겨찾기에 추가 된 경우 : 즐겨찾기 해제 / 즐겨찾기 추가 안된 경우 : 즐겨찾기 추가
    func changeFavoritePlaceStatus() {
        guard let targetPlace = targetPlace,
              let placeID = targetPlace.id else { return }
        if isFavoritePlace {
            FirestoreManager.shared.removeFavorite(placeID: placeID) { [weak self] _ in
                self?.isFavoritePlace = false
            }
        } else {
            FirestoreManager.shared.addFavoritePlace(place: targetPlace) { [weak self] in
                self?.isFavoritePlace = true
            }
        }
    }
    
    /// 해당되는 장소에 대한 세부 데이터 받아오기 (별점, 리뷰, 사진 등)
    private func setTargetPlaceData() {
        guard let placeId = self.targetPlace?.id else { return }
        
        self.startFetchingData()
        
        HttpClient.shared.getDetailDataForTargetPlace(placeCode: placeId) { [weak self] placeData in
            self?.targetPlaceData = placeData
            self?.finishFetchingData()
        }
    }
    
    private func checkIfPlaceIsFavoritePlace(placeID: String, completion: @escaping (Bool) -> Void) {
        guard userLoginStatus == true else { return }
        FirestoreManager.shared.checkIfIsFavoritePlace(placeID: placeID) { isFavoritePlace in
            if !isFavoritePlace {
                completion(false)
                return
            }
            if isFavoritePlace {
                completion(true)
                return
            }
        }
    }
}
