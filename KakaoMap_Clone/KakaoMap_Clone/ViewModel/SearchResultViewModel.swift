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
    
    private var keyword: String?
    
    private var results: [KeywordDocument]?
    
    private var tappedHistory: [SearchHistory] = []
    
    private var selectedPlace: KeywordDocument?
    
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
    
    // MARK: - Initializer
    
    init(keyword: String, results: [KeywordDocument]) {
        self.keyword = keyword
        self.results = results
    }
    
    init() { }
    
    // MARK: - Methods
    
    func updateNewTappedHistory(location: String) {
        let newTappedHistory = SearchHistory(type: UIImage(systemName: "building.2")!,
                                             searchText: location)
        self.tappedHistory.insert(newTappedHistory, at: 0)
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

}
