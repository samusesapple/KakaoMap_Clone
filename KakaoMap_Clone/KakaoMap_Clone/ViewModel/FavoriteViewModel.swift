//
//  FavoriteViewModel.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/06/14.
//

import Foundation

final class FavoriteViewModel {
    
    var placeList: [FavoritePlace]
    
    var needToReloadTableView: () -> Void = { }

    // MARK: - Initializer
    
    init(placeList: [FavoritePlace]) {
        self.placeList = placeList
    }
    
    // MARK: - Methods
    
    func getDistance(coordinate: Coordinate) {
        HttpClient.shared.getLocationAddress(coordinate: coordinate) { result in
            
        }
    }
    
    func removeFavorite(id: String) {
        FirestoreManager.shared.removeFavorite(placeID: id) { [weak self] placees in
            self?.placeList = placees
            self?.needToReloadTableView()
        }
    }
}
