//
//  NetworkManager.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/23.
//

import Foundation
import Alamofire

class HttpClient {
    
    static let shared = HttpClient()
    
    private let host = "https://dapi.kakao.com/v2/local/"
    
    private let headers : HTTPHeaders = [
        "Authorization": "KakaoAK 7191f8213395eb70804dc67e8f329611"
    ]
    
    private init() { }
    
    // MARK: - Functions
    
    private func currentAddressParameters(lon: String, lat: String) -> [String: Any] {
        [
            "x": lon,
            "y": lat
        ]
    }
    
    private func keywordParameters(query: String, lon: String, lat: String, page: Int, isAccurancy: Bool) -> [String: Any] {
        [
            "query": query,
            "x": lon,
            "y": lat,
            "page": page,
            "sort": isAccurancy ? "accuracy": "distance"
        ]
    }
    
    private func directionParameters(startLon: String, startLat: String, destinationLon: String, destinationLat: String) -> [String: Any] {
        [
            "origin": "\(startLon),\(startLat)",
            "destination": "\(destinationLon),\(destinationLat)"
        ]
    }
    
    /// 주소로 검색하기 (건물명, 도로명, 지번, 우편번호 및 좌표)
    func getLocationAddress(lon: String, lat: String, completion: @escaping (CurrentAddressResult) -> Void) {
        let url = host + "geo/coord2regioncode.json"
        AF.request(url,
                   method: .get,
                   parameters: currentAddressParameters(lon: lon, lat: lat),
                   encoding: URLEncoding.default,
                   headers: headers)
        .validate(statusCode: 200..<300)
        .responseDecodable(of: CurrentAddressResult.self) { response in
            let result = response.result
            switch result {
            case .success(let result):
                completion(result)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    /// 키워드로 검색하기 (상호명 등을 검색)
    func searchKeyword(with keyword: String, lon: String, lat: String, page: Int, isAccuracy: Bool = true, completion: @escaping (KeywordResult?) -> Void) {
        let url = host + "search/keyword.json"
        
        AF.request(url,
                   method: .get,
                   parameters: keywordParameters(query: keyword,
                                                 lon: lon,
                                                 lat: lat,
                                                 page: page,
                                                 isAccurancy: isAccuracy),
                   encoding: URLEncoding.default,
                   headers: headers)
        .validate(statusCode: 200..<600)
        .responseDecodable(of: KeywordResult.self) { response in
            let result = response.result
            switch result {
            case .success(let searchResult):
                print("keyword : \(keyword)")
                print("lon : \(lon)")
                print("lat: \(lat)")
                guard let totalPage = searchResult.meta?.pageableCount,
                      totalPage >= page else {
                    print("HTTP Client - searchKeyword 총 데이터 페이지수 : \(String(describing: searchResult.meta?.pageableCount))")
                    completion(nil)
                    return
                }
                completion(searchResult)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getDirection(startLon: String, startLat: String, destinationLon: String, destinationLat: String, completion: @escaping(DestinationResult) -> Void) {
        let url = "https://apis-navi.kakaomobility.com/v1/directions"
        
        AF.request(url,
                   method: .get,
                   parameters: directionParameters(startLon: startLon,
                                                   startLat: startLat,
                                                   destinationLon: destinationLon,
                                                   destinationLat: destinationLat),
                   encoding: URLEncoding.default,
                   headers: headers)
        .validate(statusCode: 200..<600).responseDecodable(of: DestinationResult.self) { response in
            let result = response.result
            switch result {
            case.success(let direction):
                completion(direction)
            case .failure(let error):
                print(error)
            }
        }
    }
}
