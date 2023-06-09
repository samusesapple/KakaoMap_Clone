//
//  AuthService.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/06/09.
//

import Foundation
import FirebaseAuth

struct AuthCredentials {
    let email: String
    let nickName: String
    let password: String
    let isKakaoLogin: Bool
}

typealias AuthDataResultCallback = (AuthDataResult?, Error?) -> Void

struct AuthService {

    /// 기존에 없는 새로운 유저 등록
    static func registerUser(userInfo credentials: AuthCredentials, completion: @escaping () -> Void) {
            Auth.auth().createUser(withEmail: credentials.email,
                                   password: credentials.password) { (result, error) in
                if let error = error {
                    print("AuthService ERROR : \(error.localizedDescription)")
                    return
                }
                guard let userUID = result?.user.uid else { return }
                
                let data = ["email": credentials.email,
                            "nickName": credentials.nickName,
                            "isKakaoLogin": credentials.isKakaoLogin,
                            "uid": userUID] as [String : Any]
                
                COLLECTION_USERS.document(credentials.email).setData(data) { error in
                    if let _ = error {
                        print("새로운 유저 생성하기 실해")
                        return
                    }
                    // UserDefaults에 로그인 된 유저 정보 저장
                    UserDefaultsManager.shared.setUserInfo(nickName: credentials.nickName,
                                                           email: credentials.email,
                                                           uid: userUID,
                                                           isKakaoLogin: credentials.isKakaoLogin)
                    completion()
                }
            }
        }
    
    /// 기존 유저 로그인
    static func logUserIn(withEmail email: String, password: String, completion: AuthDataResultCallback?) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
}
