//
//  UserDefaultsManager.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/06/09.
//

import Foundation

struct UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    
    private init() { }
    
    var userEmail: String {
        return UserDefaults.standard.object(forKey: "email") as! String
    }
    /// 현재 로그인 된 유저 정보를 UserDefaults에 저장한다.
    func setUserInfo(nickName: String, email: String, uid: String, isKakaoLogin: Bool) {
        UserDefaults.standard.set(nickName, forKey: "name")
        UserDefaults.standard.set(email, forKey: "email")
        UserDefaults.standard.set(uid, forKey: "uid")
        UserDefaults.standard.set(isKakaoLogin, forKey: "isKakaoLogin")
    }
    
    /// 현재 로그인 된 유저가 카카오톡 로그인을 했는지 확인하는 메서드. 카카오톡 로그인일 경우 'ture', 아닐 경우 'false'를 return 한다.
    func isKakaoLogin() -> Bool {
        return UserDefaults.standard.value(forKey: "isKakaoLogin") as! Bool
    }
    
    /// UserDefaults에 저장된 유저 정보 지우기
    func removeUserInfo() {
        UserDefaults.standard.removeObject(forKey: "name")
        UserDefaults.standard.removeObject(forKey: "email")
        UserDefaults.standard.removeObject(forKey: "uid")
        UserDefaults.standard.removeObject(forKey: "isKakaoLogin")
    }
}
