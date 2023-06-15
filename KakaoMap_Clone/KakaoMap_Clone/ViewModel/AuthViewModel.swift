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

final class AuthViewModel {
    
    var startLogin: () -> Void = { }
    
    var finishedLogin: () -> Void = { }
    
    var showLoginToast: () -> Void = { }
    
    var startFetching: () -> Void = { }
    var finishFetching: () -> Void = { }
    
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
    func logout(login: () -> Void) {
        guard let isKakaoLogin = UserDefaultsManager.shared.isKakaoLogin() else {
            login()
            return
        }
                
        if isKakaoLogin {
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
        return
    }
    
    /// 테스트용 로그아웃
    func logoutForTesting() {
        GIDSignIn.sharedInstance.signOut()
        self.handleLogout()
        print("테스트 - 완료")
        
        UserApi.shared.logout { error in
            if let _ = error {
                print("테스트 - 로그아웃 실패")
                return
            }
            print("테스트 - 카카오톡 로그아웃 완료")
        }
    }
    
    /// 유저 로그인 여부 확인 후, 유저 UserDefaults에 저장된 유저 정보 제공 (이메일, 이름, uid, 카카오 로그인 여부)
     func checkUserLoginStatus() -> UserDefaultsModel? {
        guard let _ = FirebaseAuth.Auth.auth().currentUser else {
            print("유저 로그인 안됨")
            return nil
        }
        return UserDefaultsManager.shared.getUserInfo()
    }
    
    /// 유저 즐겨찾기 리스트 받기
    func getFavoriteViewController(completion: @escaping (FavoriteViewController) -> Void) {
        guard let _ = checkUserLoginStatus() else {
            print("로그인 필요")
            showLoginToast()
            return
        }
        self.startFetching()

        FirestoreManager.shared.getFavoritePlaceList { [weak self] places in
            self?.finishFetching()

            let favoriteViewModel = FavoriteViewModel(placeList: places)
            let favoriteVC = FavoriteViewController()
            favoriteVC.viewModel = favoriteViewModel
            DispatchQueue.main.async {
                completion(favoriteVC)
            }
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
                  let imageURL = user.kakaoAccount?.profile?.profileImageUrl,
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
                      let imageURL = user.kakaoAccount?.profile?.profileImageUrl,
                      error == nil else {
                    print("새로운 유저 회원가입 필요")
                    AuthService.registerUser(userInfo: kakaoAuthCredentials) { userUID in
                        
                        // UserDefaults에 로그인 된 유저 정보 저장 - 카카오 이메일 형태로 저장
                        self?.postNotificationAndSaveUserDefault(name: nickName,
                                                           email: AuthService.kakaoEmail(email: email),
                                                           uid: userUID,
                                                           isKakaoLogin: true,
                                                           profileImageURL: imageURL)
                        self?.finishedLogin()
                    }
                    return
                }
                print("기존 존재하는 유저로 로그인하기")
                
                self?.postNotificationAndSaveUserDefault(name: nickName,
                                                   email: AuthService.kakaoEmail(email: email),
                                                   uid: result.user.uid,
                                                   isKakaoLogin: true,
                                                   profileImageURL: imageURL)
                self?.finishedLogin()
            }
        }
    }
    
    /// 구글 로그인, 유저 정보 Firestore와 UserDefaults에 저장, NotificationCenter에 구글 로그인 된 것 알리기
    private func handleGoogleLogin(presenter: UIViewController) {
        GIDSignIn.sharedInstance.signIn(withPresenting: presenter) { [weak self] result, error in
            guard error == nil else {
                print(error?.localizedDescription as Any)
                return
            }
            self?.startLogin()
            
            AuthService.handleGoogleSignIn(result: result) { profileURL, userUID in
                guard let name = result?.user.profile?.givenName,
                      let email = result?.user.profile?.email else {
                    print(#function)
                    return
                }
                self?.postNotificationAndSaveUserDefault(name: name,
                                                   email: email,
                                                   uid: userUID,
                                                   isKakaoLogin: false,
                                                   profileImageURL: profileURL)
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
    
    /// UserDefaults에 유저 정보 세팅 & NotificationCenter에 로그인 된 것 알리기
    private func postNotificationAndSaveUserDefault(name: String, email: String, uid: String, isKakaoLogin: Bool, profileImageURL: URL) {
        UserDefaultsManager.shared.setUserInfo(nickName: name,
                                               email: email,
                                               uid: uid,
                                               isKakaoLogin: isKakaoLogin,
                                               imageURL: "\(profileImageURL)")
        // 노티피케이션 센터에 로그인 됨 알리기
        NotificationManager.postloginNotification(name: name,
                                                  userEmail: email,
                                                  profileImageURL: profileImageURL,
                                                  isKakaoLogin: isKakaoLogin)
    }
}
