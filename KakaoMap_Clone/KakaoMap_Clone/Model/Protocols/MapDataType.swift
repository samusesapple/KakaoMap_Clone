//
//  MapDataType.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/06/03.
//

import Foundation

protocol MapDataType {
    /// 검색 키워드
    var keyword: String? { get set }
    /// 지도 화면의 중심 좌표
    var mapCoordinate: Coordinate { get set }
    /// 지도 화면의 주소
    var mapAddress: CurrentAddressDocument { get set }
    /// 검색 결과를 담은 배열
    var searchResults: [KeywordDocument] { get set }
    /// 유저가 선택한 검색 결과에 대한 상세 정보
    var targetPlaceData: TargetPlaceDetail? { get set }
    /// 유저의 검색 기록을 담은 배열
    var searchHistories: [SearchHistory]? { get set }
    /// 중복된 검색 기록을 제거한 유저의 검색기록을 주는 메서드
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
