//
//  SearchResultViewModel.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/24.
//

import Foundation

final class SearchResultViewModel: MapDataType {
    
// MARK: - Stored Properties

    var keyword: String?
    
    var mapCoordinate: Coordinate
    private let currentCoordinate: Coordinate = UserDefaultsManager.shared.currentCoordinate
    
    var mapAddress: CurrentAddressDocument
    
    var searchResults: [KeywordDocument]
        
    var searchHistories: [SearchHistory]? = []
    
    var targetPlaceData: TargetPlaceDetail?

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
    
    var loadingStarted = { }
    
    var finishLoading = { }
    
    var showHud = { }
    var dismissHud = { }
    
// MARK: - Initializer
    
    init(mapData: MapDataType) {
        self.mapCoordinate = mapData.mapCoordinate

        self.keyword = mapData.keyword
        self.mapAddress = mapData.mapAddress
        self.searchHistories = mapData.searchHistories
        self.searchResults = mapData.searchResults
    }
        
// MARK: - Methods
    
    func getTargetPlaceData(index: Int, completion: @escaping(TargetPlaceDetail) -> Void) {
        showHud()
        guard let placeID = searchResults[index].id else { return }
        HttpClient.shared.getDetailDataForTargetPlace(placeCode: placeID) { [weak self] placeData in
            self?.dismissHud()
            DispatchQueue.main.async {
                completion(placeData)
            }
        }
    }
    
    /// 검색 히스토리 추가
    func updateNewTappedHistory(location: KeywordDocument) {
        let newTappedHistory = SearchHistory(type: UIImage(systemName: "building.2")!,
                                             searchText: location.placeName!,
                                             address: location.addressName)
        guard let lastHistory = searchHistories?.last else {
            self.searchHistories?.insert(newTappedHistory, at: 0)
            return
        }
        if lastHistory.searchText == newTappedHistory.searchText  {
            searchHistories![searchHistories!.count-1] = newTappedHistory
        } else {
            let duplicatedHistory = searchHistories?.filter({ $0 == newTappedHistory })
            // 똑같은 이전 검색 기록 있는 경우, 해당 이전 검색기록 삭제하기
            if duplicatedHistory!.count > 0 {
                var biggestIndex = 0
                for (index, item) in searchHistories!.enumerated() {
                    if item.searchText == duplicatedHistory![0].searchText && item.type == duplicatedHistory![0].type {
                        print("중복검색 - \(index)번째 아이템")
                        biggestIndex = index
                        continue
                    }
                }
                searchHistories?.remove(at: biggestIndex)
            }
            self.searchHistories?.insert(newTappedHistory, at: 0)
        }
    }
    
    /// id에 해당되는 장소를 return
    func filterResults(with id: Int) -> KeywordDocument {
        let targetPlace = searchResults.filter({ $0.id == String(id) }).first
        self.targetPlace = targetPlace
        return targetPlace!
    }
    
    /// 정렬 검색
    func sortAccuracyAlignment(){
        guard let keyword = keyword,
              !loading else { return }
        
        loading = true
        showHud()
        
        if isMapBasedData {
            HttpClient.shared.getLocationAddress(coordinate: mapCoordinate) { [weak self] document in
                guard let address = document.documents?[0].addressName,
                      let currentCoordinate = self?.currentCoordinate
                else { return }
                self?.searchPlaces(keyword: keyword,
                                   coordinate: currentCoordinate,
                                   place: address)
                print("지도 중심 근처에 있는 장소 검색")
            }
        } else {
            searchPlaces(keyword: keyword,
                         coordinate: currentCoordinate)
            print("현재 위치 근처에 있는 장소 검색")
        }
    }
    
    private func searchPlaces(keyword: String, coordinate: Coordinate, place: String = "") {
        HttpClient.shared.searchKeyword(with: "\(place)  \(keyword)",
                                        coordinate: coordinate,
                                        page: 1,
                                        isAccuracy: isAccuracyAlignment) { [weak self] result in
            guard let newResults = result?.documents else {
                self?.finishLoading()
                return
            }
            self?.searchResults = newResults
            self?.dismissHud()
            self?.loading = false
            print("거리순 정렬 완료")
        }
    }
    
    /// 다음 페이지의 결과 띄우기
    func getNextPageResult() {
        guard let keyword = keyword,
              searchResults.count >= 15,
              !loading else { return }
        
        loading = true
        loadingStarted()
        page += 1
        
        HttpClient.shared.searchKeyword(with: "\(mapAddress) \(keyword)",
                                        coordinate: currentCoordinate,
                                        page: page,
                                        isAccuracy: isAccuracyAlignment) { [weak self] result in
            guard let newResults = result?.documents else {
                self?.finishLoading()
                return
            }
            
            newResults.forEach({ self?.searchResults.append($0)})
            self?.finishLoading()
            self?.loading = false
            print("\(String(describing: self?.page))번째 item list 가져옴")
        }
    }
    
    func getResultMapVC(targetPlace: KeywordDocument?) -> ResultMapViewController {
        let resultMapVC = ResultMapViewController()
        resultMapVC.viewModel = ResultMapViewModel(mapData: self)
        resultMapVC.viewModel.targetPlace = targetPlace
        return resultMapVC
    }
    
}
