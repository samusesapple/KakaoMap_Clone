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
    
    private func addressParameters(query: String) -> [String: Any] {
        [
            "query": query
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
    func searchAddress(with address: String, completion: @escaping (AddressResult) -> Void) {
        let url = "https://dapi.kakao.com/v2/local/search/address.json"
        AF.request(url,
                   method: .get,
                   parameters: addressParameters(query: address),
                   encoding: URLEncoding.default,
                   headers: headers)
        .validate(statusCode: 200..<300)
        .responseDecodable(of: AddressResult.self) { response in
            let result = response.result
            switch result {
            case .success(let searchAddress):
                completion(searchAddress)
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
        .validate(statusCode: 200..<300)
        .responseDecodable(of: KeywordResult.self) { response in
            let result = response.result
            switch result {
            case .success(let searchAddress):
                completion(searchAddress)
            case .failure(let error):
                print(error)
            }
        }
    }
}
