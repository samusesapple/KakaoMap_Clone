//
//  SearchResultViewModel.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/24.
//

import Foundation

class SearchResultViewModel {
    
    // MARK: - Stored Properties
    
    static let measureFormatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = .medium
        formatter.numberFormatter.maximumFractionDigits = 1
        return formatter
    }()
    
    private var longtitude: String?
    private var latitude: String?
    private var keyword: String?
    private var results: [KeywordDocument]?
    
    private var tappedHistory: [SearchHistory] = []
    
    private var selectedPlace: KeywordDocument?
    
    private var page: Int = 1
    private var loading: Bool = false
    
    var isMapBasedData: Bool = false
    var isAccuracyAlignment: Bool = true
    
    // MARK: - Computed Properties
    
    var getResults: [KeywordDocument] {
        get {
            return results ?? []
        }
        set {
            results = newValue
        }
    }
    
    var getTappedHistory: [SearchHistory] {
        return tappedHistory
    }
    
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
    
    init(lon: String, lat: String, keyword: String, results: [KeywordDocument]) {
        self.longtitude = lon
        self.latitude = lat
        self.keyword = keyword
        self.results = results
    }
    
    init() { }
    
    // MARK: - Methods
    
    func updateNewTappedHistory(location: String) {
        let newTappedHistory = SearchHistory(type: UIImage(systemName: "building.2")!,
                                             searchText: location)
        guard let lastHistory = tappedHistory.last else {
            self.tappedHistory.insert(newTappedHistory, at: 0)
            return
        }
        if lastHistory.searchText == newTappedHistory.searchText  {
            tappedHistory[tappedHistory.count-1] = newTappedHistory
        } else {
            let duplicatedHistory = tappedHistory.filter({ $0.searchText == newTappedHistory.searchText })
            // 똑같은 이전 검색 기록 있는 경우, 해당 이전 검색기록 삭제하기
            if duplicatedHistory.count > 0 {
                for (index, item) in tappedHistory.enumerated() {
                    if item.searchText == duplicatedHistory[0].searchText && item.type == duplicatedHistory[0].type {
                        tappedHistory.remove(at: index)
                        print("중복되서 지워짐 - \(index)번째 아이템")
                        return
                    }
                    return
                }
            }
            self.tappedHistory.insert(newTappedHistory, at: 0)
        }
    }
    
    func filterResults(with id: Int) -> KeywordDocument {
        let result = results?.filter({ $0.id == String(id) }).first
        return result!
    }
    
    func sortAccuracyAlignment(){
        guard let lon = longtitude,
              let lat = latitude,
              let keyword = keyword,
              !loading else { return }
        
        loading = true
        showHud()
        
        HttpClient.shared.searchKeyword(with: keyword,
                                        lon: lon,
                                        lat: lat,
                                        page: 1,
                                        isAccuracy: isAccuracyAlignment) { [weak self] result in
            guard let newResults = result?.documents else {
                self?.finishLoading()
                return
            }
            self?.results = newResults
            self?.dismissHud()
            self?.loading = false
            print("거리순 정렬 완료")
        }
    }
    
    func getNextPageResult() {
        guard let lon = longtitude,
              let lat = latitude,
              let keyword = keyword,
              let currentResultCount = results?.count,
              currentResultCount >= 15,
              !loading else { return }
        
        loading = true
        loadingStarted()
        page += 1
        
        HttpClient.shared.searchKeyword(with: keyword,
                                        lon: lon,
                                        lat: lat,
                                        page: page,
                                        isAccuracy: isAccuracyAlignment) { [weak self] result in
            guard let newResults = result?.documents else {
                self?.finishLoading()
                return
            }
            
            newResults.forEach({ self?.results?.append($0)})
            self?.finishLoading()
            self?.loading = false
            print("\(String(describing: self?.page))번째 item list 가져옴")
        }
    }
}
