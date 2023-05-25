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
    
    private init() { }
    private let headers : HTTPHeaders = [
        "Authorization": "KakaoAK 7191f8213395eb70804dc67e8f329611"
    ]
    
    // MARK: - Functions
    
    private func currentAddressParameters(lon: String, lat: String) -> [String: Any] {
        [
            "x": lon,
            "y": lat
        ]
    }
    
    private func keywordParameters(query: String, lon: String, lat: String, page: Int) -> [String: Any] {
        [
            "query": query,
            "x": lon,
            "y": lat,
            "page": page
        ]
    }
    
    /// 주소로 검색하기 (건물명, 도로명, 지번, 우편번호 및 좌표)
    func getCurrentAddress(lon: String, lat: String, completion: @escaping (CurrentAddressResult) -> Void) {
        let url = "https://dapi.kakao.com/v2/local/geo/coord2regioncode.json"
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
    func searchKeyword(with keyword: String, lon: String, lat: String, page: Int, completion: @escaping (KeywordResult) -> Void) {
        let url = "https://dapi.kakao.com/v2/local/search/keyword.json"

        AF.request(url,
                   method: .get,
                   parameters: keywordParameters(query: keyword,
                                                 lon: lon,
                                                 lat: lat,
                                                 page: page),
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
                completion(searchResult)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    /// url로부터 이미지 받아오기
    func getImage(from url: String, completion: @escaping (UIImage) -> Void) {
        let url = URL(string: url)!
        
    }
}
