//
//  SearchViewModel.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/23.
//

import UIKit

protocol MapDataType {
    var keyword: String? { get set }
    var mapLongitude: String { get set }
    var mapLatitude: String { get set }
    
    var currentLongtitude: Double { get set }
    var currentLatitude: Double { get set }
    
    var mapAddress: String { get set }
    
    var searchResults: [KeywordDocument] { get set }

    var searchHistories: [SearchHistory]? { get set }
}

class SearchViewModel: MapDataType {
// MARK: - Stored Properties
    
    var keyword: String?
    
    var mapLongitude: String
    var mapLatitude: String
    
    var currentLongtitude: Double
    var currentLatitude: Double
    
    var mapAddress: String
    
    var searchResults: [KeywordDocument] = [] {
        didSet {
            presentResultVC()
        }
    }
    
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
    
    var presentResultVC = { }
    
// MARK: - Initializer
    
    init(mapLon: String, mapLat: String, currentLon: Double, currentLat: Double, mapAddress: String) {
        self.mapLongitude = mapLon
        self.mapLatitude = mapLat
        self.currentLongtitude = currentLon
        self.currentLatitude = currentLat
        self.mapAddress = mapAddress
    }
        
    
// MARK: - Functions
    
    func updateNewSearchHistory(_ newHistories: [SearchHistory]) {
        self.searchHistories = newHistories
    }
    
    func getSearchResultVC() -> SearchResultViewController {
        let resultVM = SearchResultViewModel(mapData: self)
        let searchReesultVC = SearchResultViewController()
        searchReesultVC.viewModel = resultVM
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
        if "\(currentLongtitude)+\(currentLatitude)" != "\(mapLongitude) + \(mapLatitude)" {
            HttpClient.shared.getLocationAddress(lon: mapLongitude, lat: mapLatitude) { [weak self] result in
                guard let address = result.documents?[0].addressName,
                      let lon = self?.currentLongtitude,
                      let lat = self?.currentLatitude else { return }
                
                self?.search(keyword: keyword,
                             lon: String(lon),
                             lat: String(lat),
                             address: address, completion: { keywordResultArray in
                    self?.searchResults = keywordResultArray
                })
            }
        } else {
            search(keyword: keyword,
                   lon: String(currentLongtitude),
                   lat: String(currentLatitude)) { [weak self] keywordResultArray in
                self?.searchResults = keywordResultArray
            }
        }
    }
    
    private func search(keyword: String, lon: String, lat: String, address: String = "", completion: @escaping ([KeywordDocument]) -> Void) {
        self.mapAddress = address
        
        HttpClient.shared.searchKeyword(with: address == "" ? keyword : "\(address) \(keyword)",
                                        lon: String(lon),
                                        lat: String(lat),
                                        page: 1) { [weak self] result in
            guard let keywordResultArray = result?.documents,
                  let totalPage = result?.meta?.pageableCount,
                      totalPage > 1 else {
                print("SearchVM - 결과 없음")
                self?.dismissProgressHUD()
                return
            }
            
            // 검색 히스토리 배열에 추가하기
            let newHistory = SearchHistory(type: UIImage(systemName: "magnifyingglass")!, searchText: keyword)
            
            if (self?.searchHistories) != nil {
                print("SearchVM - newHistory KEYWORD : \(keyword)")
                // 이미 해당 키워드로 검색한 이력이 있는지 확인 후, 있으면 삭제 필요함
                self?.checkIfDuplicatedHistoryExists(newHistory: newHistory)
                self?.dismissProgressHUD()
                completion(keywordResultArray)
            } else {
                print("SearchVM - newHistory KEYWORD 로 배열 초기화")
                self?.searchHistories = [newHistory]
                self?.dismissProgressHUD()
                completion(keywordResultArray)
            }
        }
    }
    
    private func checkIfDuplicatedHistoryExists(newHistory: SearchHistory) {
        guard var history = searchHistories else { return }
        let duplicatedHistoryArray = history.filter({ $0 == newHistory })
        
        guard duplicatedHistoryArray.count > 0 else { return }
                
        for (index, item) in history.enumerated() {
            if item == duplicatedHistoryArray[0] {
                history.remove(at: index)
                continue
            }
        }
        history.insert(newHistory, at: 0)
        searchHistories = history
    }
    
}
