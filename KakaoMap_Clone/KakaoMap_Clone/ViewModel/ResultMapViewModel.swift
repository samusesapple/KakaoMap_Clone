//
//  ResultMapViewModel.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/30.
//

import Foundation

class ResultMapViewModel: MapDataType {
    
    var keyword: String?
    
    var mapLongitude: String
    var mapLatitude: String
    
    var currentLongtitude: Double
    var currentLatitude: Double
    
    var mapAddress: String
    
    var searchResults: [KeywordDocument]
    var searchHistories: [SearchHistory]?
    
    private var selectedPlace: KeywordDocument?
    
    private var page: Int = 1
    private var loading: Bool = false
    
    var isMapBasedData: Bool = true
    var isAccuracyAlignment: Bool = true
    
// MARK: - Computed Properties

    var targetPlace: KeywordDocument? {
        get {
            return selectedPlace
        }
        set {
            selectedPlace = newValue
        }
    }
    
// MARK: - Initializer
    
    init(mapData: MapDataType) {
        keyword = mapData.keyword
        mapLongitude = mapData.mapLongitude
        mapLatitude = mapData.mapLatitude
        currentLongtitude = mapData.currentLongtitude
        currentLatitude = mapData.currentLatitude
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
              let destinationLat = targetPlace.y else { return }
        
        HttpClient.shared.getDirection(startLon: String(currentLongtitude),
                                       startLat: String(currentLatitude),
                                       destinationLon: destinationLon,
                                       destinationLat: destinationLat) { result in
            guard let routes = result.routes else {
                print("자동차 경로 없음")
                return
            }
            guard let sections = routes[0].sections,
                  let guides = sections[0].guides else { return }
            completion(guides)
        }
    }
    
}
