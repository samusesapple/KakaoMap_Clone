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
    
    var isMapBasedData: Bool = true
    var isAccurancyAlignment: Bool = true
    
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
    
    func sortByDistance(){
        let sortedResult = results?.sorted(by: { firstData, secondData in
            guard let stringDistance1 = firstData.distance,
                  let stringDistance2 = firstData.distance,
                  let distance1 = Int(stringDistance1),
                  let distance2 = Int(stringDistance2) else { return false }
            return distance1 > distance2
        })
        self.results = sortedResult
    }

    func getNextPageResult() {
        if loading { return }
        loading = true
        loadingStarted()
        page += 1
        guard let lon = longtitude,
              let lat = latitude,
              let keyword = keyword else { return }
        HttpClient.shared.searchKeyword(with: keyword,
                                        lon: lon,
                                        lat: lat,
                                        page: page) { [weak self] result in
            guard let newResults = result.documents else { return }
            newResults.forEach({ self?.results?.append($0)})
            self?.finishLoading()
            self?.loading = false
            print("\(String(describing: self?.page))번째 item list 가져옴")
        }
//        repository.next(currentPage: lectureList) {
//            var lectureList = $0
//            lectureList.lectures.insert(contentsOf: self.lectureList.lectures, at: 0)
//            self.lectureList = lectureList
//            self.lectureListUpdated()
//            self.loadingEnded()
//            self.loading = false
//        }
    }
}
