//
//  AuthViewModel.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/06/09.
//

import Foundation
import KakaoSDKUser
import FirebaseAuth

class AuthViewModel {
    
    var startLogin: () -> Void = { }
    
    var finishedLogin: () -> Void = { }
    
// MARK: - Methods
    
    /// 카카오톡 로그인하기
    func kakaotalkLogin() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { [weak self] token, error in
                if let error = error {
                    print(error)
                    return
                }
                print("카카오 로그인 성공")
                _ = token
                // 로그인 된 카카오톡 정보 노티피케이션 센터에 등록 및 메뉴에 있는 프로필 세팅하기
                // firebase에 해당 카카오톡 아이디로 회원가입 유무 확인 후, 없으면 가입하고 있으면 로그인시키기
                self?.setFirebaseForKakaoTalkLogin()
            }
        }
    }
     
    private func setFirebaseForKakaoTalkLogin() {
        UserApi.shared.me {[weak self] user, error in
            guard let user = user,
                  let email = user.kakaoAccount?.email,
                  let nickName = user.kakaoAccount?.profile?.nickname,
                  let password = user.id,
                  error == nil else {
                print(error!)
                return
            }
            
            self?.startLogin()
            
            let kakaoAuthCredentials = AuthCredentials(email: email,
                                                       nickName: nickName,
                                                       password: String(password),
                                                       isKakaoLogin: true)
            
            AuthService.logUserIn(withEmail: email, password: String(password)) { result, error in
                guard let result = result,
                      let email = result.user.email,
                      error == nil else {
                    print("새로운 유저 회원가입 필요")
                    AuthService.registerUser(userInfo: kakaoAuthCredentials) {
                        
                        NotificationManager.postloginNotification(name: nickName,
                                                                  userEmail: email,
                                                                  profileImageURL: user.kakaoAccount?.profile?.profileImageUrl,
                                                                  isKakaoLogin: true)
                        self?.finishedLogin()
                    }
                    return
                }
                print("기존 존재하는 유저로 로그인하기")
                UserDefaultsManager.shared.setUserInfo(nickName: nickName,
                                                       email: email,
                                                       uid: result.user.uid,
                                                       isKakaoLogin: true)
                
                NotificationManager.postloginNotification(name: nickName,
                                                          userEmail: email,
                                                          profileImageURL: user.kakaoAccount?.profile?.profileImageUrl,
                                                          isKakaoLogin: true)
                self?.finishedLogin()
            }
        }
    }
    
    /// 로그아웃 하기
    func logout() {
        if UserDefaultsManager.shared.isKakaoLogin() {
            UserApi.shared.logout { [weak self] error in
                if let _ = error {
                    print("로그아웃 실패")
                    return
                }
                print("카카오톡 로그아웃 완료")
                self?.handleLogout()
            }
        } else {
            self.handleLogout()
        }
    }
    
    private func handleLogout() {
        try! FirebaseAuth.Auth.auth().signOut()
        UserDefaultsManager.shared.removeUserInfo()
        // 로그아웃 상태 노티피케이션 post 하기
        NotificationManager.postLogoutNotification()
    }
}
