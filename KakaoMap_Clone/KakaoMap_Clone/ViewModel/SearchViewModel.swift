//
//  SearchViewModel.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/23.
//

import Foundation

struct SearchOption {
    var icon: UIImage
    var title: String
}

struct SearchHistory {
    var type: UIImage
    var searchText: String
}

class SearchViewModel {
    
    // MARK: - Stored Properties
    
    private let searchOptions: [SearchOption] = {[
        SearchOption(icon: UIImage(systemName: "fork.knife")!, title: "맛집"),
        SearchOption(icon: UIImage(systemName: "cup.and.saucer.fill")!, title: "카페"),
        SearchOption(icon: UIImage(systemName: "24.square.fill")!, title: "편의점"),
        SearchOption(icon: UIImage(systemName: "cart.fill")!, title: "마트"),
        SearchOption(icon: UIImage(systemName: "pill.fill")!, title: "약국"),
        SearchOption(icon: UIImage(systemName: "train.side.rear.car")!, title: "지하철")
    ]}()
    
    private var searchHistories: [SearchHistory]?
    
    private var searchPage: Int = 1
    
    private var longitude: String?
    private var latitude: String?
    
    // MARK: - Computed Properties
    /// [get] searchOption 배열 받기
    var getSearchOptions: [SearchOption] {
        return searchOptions
    }
    /// [get] searchHistory 배열 받기
    var getSetSearchHistories: [SearchHistory] {
        return searchHistories ?? []
    }
    
    // MARK: - Lifecycle
    
    init(lon: String, lat: String) {
        self.longitude = lon
        self.latitude = lat
    }
    
    init() { }
    
    
    // MARK: - Functions
    /// 글자수에 따라 collectionView Cell의 넓이 측정하여 Double 형태로 return
    func getCellWidth(with option: SearchOption) -> Double {
        if option.title.count <= 2 {
            return Double(option.title.count * 30)
        } else {
            return Double(option.title.count * 25)
        }
    }
    
    /// 주소 검색하기 >> return: 위도, 경도, Address, RoadAddress
    func getAddressSearchResult(with address: String, completion: @escaping (String, String, Address, RoadAddress) -> Void) {
        HttpClient.shared.searchAddress(with: address) { [weak self] result in
            guard let document = result.documents?.first else {
                print("SearchVM - document 없음")
                return
            }
            guard let longitude = document.x,
                  let latitude = document.y,
                  let addressData = document.address,
                  let roadAddress = document.roadAddress else { return }
            // 검색 히스토리 배열에 추가하기
            let newHistory = SearchHistory(type: UIImage(systemName: "magnifyingglass")!, searchText: roadAddress.buildingName ?? address)
            
            if (self?.searchHistories) != nil {
                print("SearchVM - newHistory : \(newHistory)")
                self?.searchHistories?.append(newHistory)
                completion(latitude, longitude, addressData, roadAddress)
            } else {
                print("SearchVM - newHistory로 배열 초기화")
                self?.searchHistories = [newHistory]
                completion(latitude, longitude, addressData, roadAddress)
            }
        }
    }
    
    func getKeywordSearchResult(with keyword: String, completion: @escaping([Result]) -> Void) {
        guard let lon = longitude,
                let lat = latitude else {
            print(#function)
            return
        }
        HttpClient.shared.searchKeyword(with: keyword,
                                        lon: lon,
                                        lat: lat,
                                        page: searchPage) { result in
            guard let keywordResultArray = result.documents else {
                print("SearchVM - 결과 없음")
                return
            }
            print(keywordResultArray.first?.placeName as Any)
            completion(keywordResultArray)
        }
    }
    
}
