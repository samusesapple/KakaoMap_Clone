//
//  Constant.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/06/09.
//

import FirebaseFirestore

/// Firestore - 유저 정보 컬렉션
let COLLECTION_USERS = Firestore.firestore().collection("users")

/// Firestore - 장소 정보 컬렉션
let COLLECTION_PLACES = Firestore.firestore().collection("places")
