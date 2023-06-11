//
//  Constant.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/06/09.
//

import FirebaseFirestore

/// Firestore - 유저 정보 컬렉션
let COLLECTION_USERS = Firestore.firestore().collection("users")

/// Firestore - 접속한 유저의 즐겨찾기 한 장소 다큐먼트
let COLLECTION_FAVORITE = Firestore.firestore().collection("favorites")
