//
//  NotificationManager.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/06/08.
//

import Foundation

struct NotificationManager {
    
    static var loginNotificationName: Notification.Name {
        return Notification.Name("userLoginNotification")
    }
    
    static var logoutNoficationName: Notification.Name {
        return Notification.Name("userLogOutNotification")
    }
    
    static func postloginNotification(name: String?, userEmail: String?, profileImageURL: URL?, isKakaoLogin: Bool) {
        guard let name = name,
              let userEmail = userEmail,
              let profileImageURL = profileImageURL else {
            print("노티 매니저 - 옵셔널 벗기기 실패")
            return
        }
       let loginNotification = Notification(name: loginNotificationName,
                                            object: ["userName": name,
                                                     "userEmail": userEmail,
                                                     "profileImageURL": profileImageURL,
                                                     "isKakaoLogin": isKakaoLogin
                                                    ] as [String : Any])
        NotificationCenter.default.post(loginNotification)
    }
    
    static func postLogoutNotification() {
        let logoutNotification = Notification(name: logoutNoficationName)
        NotificationCenter.default.post(logoutNotification)
    }
}
