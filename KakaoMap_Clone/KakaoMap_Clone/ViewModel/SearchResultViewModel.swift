//
//  SearchResultViewModel.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/24.
//

import Foundation

class SearchResultViewModel {
    
    // MARK: - Stored Properties
    
    private var keyword: String?
    
    private var results: [Any]?
    
    private var tappedHistory: [SearchHistory] = []
    
    // MARK: - Computed Properties
    
    var getResults: [Any] {
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
    
    // MARK: - Initializer
    
    init(keyword: String, results: [Any]) {
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
    
}
