//
//  SearchViewModel.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/23.
//

import UIKit

class SearchViewModel: MapDataType {
    
// MARK: - Stored Properties
    
    var keyword: String? {
        didSet {
            // 키워드 변경 될 때마다 searchBar text를 키워드로 세팅하기
            setSearchBar(keyword)
        }
    }
    
    private let currentCoordinate: Coordinate = UserDefaultsManager.shared.currentCoordinate
    
    var mapCoordinate: Coordinate
    
    var mapAddress: String
    
    var searchResults: [KeywordDocument] = [] {
        didSet {
            // 네트워킹으로 검색 결과가 나오면, 검색 결과를 보여주는 SearchResultVC 띄우기
            presentResultVC()
        }
    }
    
    var targetPlaceData: CertainPlaceData?

    var searchHistories: [SearchHistory]?

    private let searchOptions: [SearchOption] = {[
        SearchOption(icon: UIImage(systemName: "fork.knife")!, title: "맛집"),
        SearchOption(icon: UIImage(systemName: "cup.and.saucer.fill")!, title: "카페"),
        SearchOption(icon: UIImage(systemName: "24.square.fill")!, title: "편의점"),
        SearchOption(icon: UIImage(systemName: "cart.fill")!, title: "마트"),
        SearchOption(icon: UIImage(systemName: "pill.fill")!, title: "약국"),
        SearchOption(icon: UIImage(systemName: "train.side.rear.car")!, title: "지하철")
    ]}()
    
// MARK: - Computed Properties
    /// [get] searchOption 배열 받기
    var getSearchOptions: [SearchOption] {
        return searchOptions
    }
    
    var showProgressHUD = { }
    var dismissProgressHUD = { }
    
    /// 결과 보여주는 ResultVC 띄우기
    var presentResultVC = { }
    
    /// 지정된 장소의 결과를 보여주는 지도, MapVC 띄우기
    var presentResultMapVC: (KeywordDocument) -> Void = { _ in }
    
    /// 검색 키워드로 SearchBar UI 세팅하기
    var setSearchBar: (String?) -> Void = { _ in }
    
// MARK: - Initializer
    
    init(mapCoordinate: Coordinate, mapAddress: String) {
        self.mapCoordinate = mapCoordinate
        self.mapAddress = mapAddress
    }
        
// MARK: - Functions
    
    /// 새로운 검색 결과 초기화하기
    func updateNewSearchHistory(_ newHistories: [SearchHistory]) {
        self.searchHistories = newHistories
    }
    
    /// 검색 결과 보여주기
    func getSearchResultVC() -> SearchResultViewController {
        let resultVM = SearchResultViewModel(mapData: self)
        let searchReesultVC = SearchResultViewController()
        searchReesultVC.viewModel = resultVM
        return searchReesultVC
    }
    
    /// 검색 기록 장소 누른 경우 - 지도로 결과 보여주기
    func getResultMapVC(targetPlace: KeywordDocument) -> ResultMapViewController {
        let resultVM = ResultMapViewModel(mapData: self)
        let searchReesultVC = ResultMapViewController()
        searchReesultVC.viewModel = resultVM
        searchReesultVC.viewModel.targetPlace = targetPlace
        searchReesultVC.viewModel.keyword = targetPlace.placeName
        return searchReesultVC
    }
    
    /// 글자수에 따라 collectionView Cell의 넓이 측정하여 Double 형태로 return
    func getCellWidth(with option: SearchOption) -> Double {
        if option.title.count <= 2 {
            return Double(option.title.count * 30)
        } else {
            return Double(option.title.count * 25)
        }
    }
    
    /// 키워드로 검색하기
    func getKeywordSearchResult(with keyword: String) {
        showProgressHUD()
        self.keyword = keyword
        
        if currentCoordinate.totalCoordinate != mapCoordinate.totalCoordinate {
            HttpClient.shared.getLocationAddress(coordinate: mapCoordinate) { [weak self] result in
                guard let address = result.documents?[0].addressName,
                      let currentCoordinate = self?.currentCoordinate
                else {
                    print(#function)
                    self?.dismissProgressHUD()
                    return
                }
                
                self?.search(keyword: keyword,
                             currentCoordinate: currentCoordinate,
                             address: address, completion: { keywordResultArray in
                    self?.searchResults = keywordResultArray
                })
            }
        } else {
            search(keyword: keyword,
                   currentCoordinate: currentCoordinate) { [weak self] keywordResultArray in
                self?.searchResults = keywordResultArray
            }
        }
    }
    
    /// 유저 현재 좌표 기준으로 특정 키워드에 해당되는 장소 제공 / address부분에 원하는 지역 입력하면 해당 지역의 키워드 장소 제공
    private func search(keyword: String, currentCoordinate: Coordinate, address: String = "", completion: @escaping ([KeywordDocument]) -> Void) {
        self.mapAddress = address
        
        HttpClient.shared.searchKeyword(with: address == "" ? keyword : "\(address) \(keyword)",
                                        coordinate: currentCoordinate,
                                        page: 1) { [weak self] result in
            guard let keywordResultArray = result?.documents,
                  let totalPage = result?.meta?.pageableCount,
                      totalPage > 1 else {
                print("SearchVM - 결과 없음")

                self?.dismissProgressHUD()
                return
            }
            
            // 검색 히스토리 배열에 추가하기
            let newHistory = SearchHistory(type: UIImage(systemName: "magnifyingglass")!, searchText: keyword, address: nil)
            
            if (self?.searchHistories) != nil {
                print("SearchVM - newHistory KEYWORD : \(keyword)")
                // 이미 해당 키워드로 검색한 이력이 있는지 확인 후, 있으면 삭제 필요함
                guard let historyArray = self?.checkIfDuplicatedHistoryExists(newHistory: newHistory) else {
                    print("겹치는 검색어 없음")
                    self?.searchHistories?.insert(newHistory, at: 0)
                    self?.dismissProgressHUD()
                    completion(keywordResultArray)
                    return
                }
                print("겹치는 검색어 있음")
                self?.searchHistories = historyArray
                self?.dismissProgressHUD()
                completion(keywordResultArray)
                return
            }
            else {
                print("SearchVM - newHistory KEYWORD 로 배열 초기화")
                self?.searchHistories = [newHistory]
                self?.dismissProgressHUD()
                completion(keywordResultArray)
                return
            }
        }
    }
        
    /// Search History에 해당되는 장소 보여주기
    func getTargetPlace(with searchText: String) {
        guard let history = self.searchHistories else { return }
        showProgressHUD()
        
        self.keyword = searchText

        let target = history.filter({ $0.searchText == searchText})[0]
        HttpClient.shared.searchKeyword(with: target.searchText,
                                        coordinate: currentCoordinate,
                                        page: 1) { [weak self] result in
            guard let documents = result?.documents else {
                self?.dismissProgressHUD()
                return
            }
            let targetPlace = documents.filter( { $0.addressName == target.address })[0]
            // 맵 VC 띄우도록 하기
            self?.dismissProgressHUD()
            self?.presentResultMapVC(targetPlace)
        }
    }
    
//    private func checkIfDuplicatedHistoryExists(newHistory: SearchHistory) {
//        guard var history = searchHistories else { return }
//        let duplicatedHistoryArray = history.filter({ $0 == newHistory })
//
//        guard duplicatedHistoryArray.count > 0 else { return }
//
//        for (index, item) in history.enumerated() {
//            if item == duplicatedHistoryArray[0] {
//                history.remove(at: index)
//                continue
//            }
//        }
//        history.insert(newHistory, at: 0)
//        searchHistories = history
//    }
//
}
