//
//  AuthViewModel.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/06/09.
//

import Foundation
import KakaoSDKUser
import FirebaseAuth
import GoogleSignIn

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
    
    /// 구글 로그인하기
    func googleLogin(presenter: UIViewController) {
        let clientID = FirebaseAuth.Auth.auth().app?.options.clientID
        let googleConfig = GIDConfiguration(clientID: clientID!)
        GIDSignIn.sharedInstance.configuration = googleConfig
        handleGoogleLogin(presenter: presenter)
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
            GIDSignIn.sharedInstance.signOut()
            self.handleLogout()
            print("구글 로그아웃 완료")
        }
    }
    
// MARK: - Helpers
    /// 카카오톡 로그인 된 유저 정보를 Firebase에 저장 / Firebase 앱 로그인 실행, NotificationCenter에 카카오톡 로그인 알리기
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
                    AuthService.registerUser(userInfo: kakaoAuthCredentials) { userUID in
                        
                        // UserDefaults에 로그인 된 유저 정보 저장 - 카카오 이메일이 아닌 기존의 이메일 저장하기
                        UserDefaultsManager.shared.setUserInfo(nickName: nickName,
                                                               email: email,
                                                               uid: userUID,
                                                               isKakaoLogin: true)
                        
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
    
    /// 구글 로그인, 유저 정보 Firestore에 저장, NotificationCenter에 구글 로그인 된 것 알리기
    private func handleGoogleLogin(presenter: UIViewController) {
        GIDSignIn.sharedInstance.signIn(withPresenting: presenter) { [weak self] result, error in
            guard error == nil else {
                print(error?.localizedDescription as Any)
                return
            }
            self?.startLogin()
            
            AuthService.handleGoogleSignIn(result: result) { profileURL in
                guard let name = result?.user.profile?.name,
                      let email = result?.user.profile?.email else {
                    print(#function)
                    return
                }
                // 노티피케이션 센터에 로그인 됨 알리기
                NotificationManager.postloginNotification(name: name,
                                                          userEmail: email,
                                                          profileImageURL: profileURL,
                                                          isKakaoLogin: false)
                print("구글 로그인 완료")
                self?.finishedLogin()
            }
        }
    }
    
    /// Firebase 로그아웃, UserDefaults에 저장된 유저 정보 제거, NotificationCenter에 로그아웃 된 것을 알리기
    private func handleLogout() {
        try! FirebaseAuth.Auth.auth().signOut()
        UserDefaultsManager.shared.removeUserInfo()
        // 로그아웃 상태 노티피케이션 post 하기
        NotificationManager.postLogoutNotification()
    }
}
