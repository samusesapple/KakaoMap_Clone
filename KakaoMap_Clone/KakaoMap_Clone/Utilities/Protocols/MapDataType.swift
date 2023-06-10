//
//  MapDataType.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/06/03.
//

import Foundation

protocol MapDataType {
    var keyword: String? { get set }
    
    var mapCoordinate: Coordinate { get set }
    
    var mapAddress: String { get set }
    
    var searchResults: [KeywordDocument] { get set }
    
    var targetPlaceData: CertainPlaceData? { get set }
    
    var searchHistories: [SearchHistory]? { get set }
    
    func checkIfDuplicatedHistoryExists(newHistory: SearchHistory) -> [SearchHistory]?
}

extension MapDataType {
    func checkIfDuplicatedHistoryExists(newHistory: SearchHistory) -> [SearchHistory]? {
        guard var history = searchHistories else { return nil }
        let duplicatedHistoryArray = history.filter({ $0 == newHistory })
        
        guard duplicatedHistoryArray.count > 0 else { return nil }
                
        var biggestIndex = 0
        
        for (index, item) in history.enumerated() {
            if item == duplicatedHistoryArray[0] {
                biggestIndex = index
                continue
            }
        }
        history.remove(at: biggestIndex)
        history.insert(newHistory, at: 0)
        return history
    }
    
}
