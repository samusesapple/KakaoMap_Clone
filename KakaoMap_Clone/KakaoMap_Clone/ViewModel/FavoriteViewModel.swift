//
//  FavoriteViewModel.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/06/14.
//

import Foundation

final class FavoriteViewModel {
    
    var placeList: [FavoritePlace] = []
    
    private var isEmpty: Bool {
        didSet {
            print(isEmpty)
        }
    }
    
    var needToSetPlaceHolder: (Bool) -> Void = { _ in }
    
    var needToReloadTableView: () -> Void = { }

    // MARK: - Initializer
    
    init(placeList: [FavoritePlace]) {
        self.isEmpty = placeList.isEmpty
        self.placeList = placeList
    }
    
    // MARK: - Methods
    
    func getDistance(placeId: String, placeName: String, completion: @escaping (String) -> Void) {
        HttpClient.shared.searchKeyword(with: placeName,
                                        coordinate: UserDefaultsManager.shared.currentCoordinate,
                                        page: 1) { result in
            guard let result = result,
                  let docs = result.documents else { return }
            let target = docs.filter { $0.id == placeId }[0]

            guard let distance = target.distance else { return }
            completion(distance)
        }
    }
    
    func removeFavorite(id: String) {
        FirestoreManager.shared.removeFavorite(placeID: id) { [weak self] placees in
            self?.placeList = placees
            self?.isEmpty = placees.isEmpty
            self?.needToReloadTableView()
        }
    }
}
