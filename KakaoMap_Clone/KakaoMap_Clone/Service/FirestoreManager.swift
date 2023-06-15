//
//  FirestoreManager.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/06/11.
//

import Foundation

struct FirestoreManager {
    static let shared = FirestoreManager()
    
    private init() { }
    
    /// 즐겨찾기에 장소 추가하기
    func addFavoritePlace(place: KeywordDocument, completion: @escaping () -> Void) {
        guard let placeName = place.placeName,
              let placeId = place.id,
              let address = place.roadAddressName,
              let longtitude = place.x,
              let latitude = place.y else { return }
        
        let uid = UserDefaultsManager.shared.getUserInfo().uid
        
        let data = ["placeName": placeName, // 장소명
                    "placeID": placeId, // 장소 고유 id
                    "address": address, // 도로명 주소
                    "coordinate": [     // 해당 장소의 위치 좌표
                        "longtitude": longtitude, // 위도
                        "latitude": latitude // 경도
                    ]] as [String : Any]
        
        COLLECTION_FAVORITE.document(uid).collection("favorites").document(placeId).setData(data) { error in
            if let _ = error {
                print("즐겨찾기 장소 추가 실패")
                return
            }
            completion()
        }
    }
    
    /// 즐겨찾기 저장된 장소들 데이터 받기
    func getFavoritePlaceList(completion: @escaping ([FavoritePlace]) -> Void) {
        let userUID = UserDefaultsManager.shared.getUserInfo().uid
        COLLECTION_FAVORITE.document(userUID).collection("favorites").getDocuments { snapshot, error in
            guard let data = snapshot else { return }
            let favorites = data.documents.map { FavoritePlace(dictionary: $0.data()) }
            
            completion(favorites)
        }
    }
    
    /// 즐겨찾기 취소
    func removeFavorite(placeID: String, completion: @escaping ([FavoritePlace]) -> Void) {
        let userUID = UserDefaultsManager.shared.getUserInfo().uid
        COLLECTION_FAVORITE.document(userUID).collection("favorites").document(placeID).delete { error in
            if let error = error {
                print("즐겨찾기 삭제 실패 : \(error)")
                return
            }
            print("삭제 성공")
            getFavoritePlaceList { favoritePlaces in
                completion(favoritePlaces)
            }
        }
    }
    
    /// 특정 장소가 즐겨찾기에 추가된 장소인지 확인 (즐겨찾기에 추가된 장소인 경우 true, 아닌 경우 false를 리턴)
    func checkIfIsFavoritePlace(placeID: String, completion: @escaping (Bool) -> Void) {
        let userUID = UserDefaultsManager.shared.getUserInfo().uid
        COLLECTION_FAVORITE.document(userUID).collection("favorites").document(placeID).getDocument { data, error in
            guard let data = data,
                  data.exists == true
                else {
                print("즐겨찾기에 해당되는 장소 아님")
                completion(false)
                return
            }
            print("즐겨찾기에 해당되는 장소")
            completion(true)
        }
    }
}
