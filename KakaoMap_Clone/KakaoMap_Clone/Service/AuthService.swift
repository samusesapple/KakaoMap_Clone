//
//  AuthService.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/06/09.
//

import Foundation
import FirebaseAuth
import GoogleSignIn

struct AuthCredentials {
    let email: String
    let nickName: String
    let password: String
    let isKakaoLogin: Bool
}

typealias AuthDataResultCallback = (AuthDataResult?, Error?) -> Void

struct AuthService {
    
    /// [카카오톡 로그인에 사용] 기존에 없는 새로운 유저 등록 -> userUID return
    static func registerUser(userInfo credentials: AuthCredentials, completion: @escaping (String) -> Void) {
        let kakaoEmail = kakaoEmail(email: credentials.email)
                                    
        Auth.auth().createUser(withEmail: kakaoEmail,
                               password: credentials.password) { (result, error) in
            if let error = error {
                print("AuthService ERROR : \(error.localizedDescription)")
                return
            }
            guard let userUID = result?.user.uid else { return }
            
            let data = ["email": kakaoEmail,
                        "nickName": credentials.nickName,
                        "isKakaoLogin": credentials.isKakaoLogin,
                        "uid": userUID] as [String : Any]
            
            COLLECTION_USERS.document(kakaoEmail).setData(data) { error in
                if let _ = error {
                    print("새로운 유저 생성하기 실해")
                    return
                }
                completion(userUID)
            }
        }
    }
    
    /// [카카오톡 로그인에 사용] 기존 유저 로그인
    static func logUserIn(withEmail email: String, password: String, completion: AuthDataResultCallback?) {
        let kakaoEmail = kakaoEmail(email: email)
        Auth.auth().signIn(withEmail: kakaoEmail, password: password, completion: completion)
    }
    
    /// 구글 로그인 및 UserDefaults에 유저 정보 저장
    static func handleGoogleSignIn(result: GIDSignInResult?, completion: @escaping (URL, String) -> Void) {
                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString
                else {
                // 토큰 오류
                    return
                }
                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                               accessToken: user.accessToken.tokenString)
                guard let email = user.profile?.email,
                      let userName = user.profile?.givenName else { return }
            
        FirebaseAuth.Auth.auth().signIn(with: credential) { result, error in
            guard let userUID = result?.user.uid,
                  let imageURL = result?.user.photoURL,
                    error == nil else {
                print("GOOGLE - credential error")
                return
            }
            let data = ["email": email,
                        "nickName": userName,
                        "isKakaoLogin": false,
                        "uid": userUID] as [String : Any]
            
            COLLECTION_USERS.document(email).setData(data) { error in
                guard error == nil else {
                    print(error!)
                    return
                }
                
                completion(imageURL, userUID)
            }
        }
    }
    
    /// 카카오 로그인인 경우 기존의 이메일에 카카오 표식 붙여서 이메일 중복 방지
    static func kakaoEmail(email: String) -> String {
        return "kakao_" + email
    }
}
