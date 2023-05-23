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
    
    private let url = "https://dapi.kakao.com/v2/local/search/address.json"
    private let headers : HTTPHeaders = [
        "Authorization": "KakaoAK 7191f8213395eb70804dc67e8f329611"
    ]
    
    // MARK: - Functions
    
    private func getParameters(address: String) -> [String: Any] {
        [
            "query": address,
        ]
    }
    
    func search(with address: String, completion: @escaping (SearchAddress) -> Void) {
        AF.request(url,
                   method: .get,
                   parameters: getParameters(address: address),
                   encoding: URLEncoding.default,
                   headers: headers)
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SearchAddress.self) { response in
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
