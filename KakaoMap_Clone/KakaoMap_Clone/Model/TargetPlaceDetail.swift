//
//  CertainPlaceData.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/06/10.
//
import Foundation

// MARK: - CertainPlaceData
struct TargetPlaceDetail: Codable {
    let basicInfo: BasicInfo?
    let comment: Comment?
    let menuInfo: MenuInfo?
    let photo: Photo?

    enum CodingKeys: String, CodingKey {
        case basicInfo
        case comment, menuInfo, photo
    }
}

// MARK: - BasicInfo
struct BasicInfo: Codable {
    let cid: Int?
    let placenamefull: String?
    let mainphotourl: String?  // 대표 이미지 url
    let phonenum: String? // 가게 전화번호
    let address: Address? // 가게 주소
    let homepage: String? // 가게 홈페이지 주소
    let homepagenoprotocol: String?
    let category: Category?
    let feedback: [String: Int]?
    let openHour: OpenHour? // 오픈 시간
    let operationInfo: OperationInfo? // 운영 정보 (배달 가능, 예약, 포장 등)
}

// MARK: - Address
struct Address: Codable {
    let addrdetail: String? // 상세 주소
}

// MARK: - Category
struct Category: Codable {
    let cateid, catename, cate1Name: String?

    enum CodingKeys: String, CodingKey {
        case cateid, catename
        case cate1Name = "cate1name"
    }
}

// MARK: - FacilityInfo
struct FacilityInfo: Codable {
    let wifi, pet, parking, fordisabled: String?
    let nursery, smokingroom: String?
}

// MARK: - OpenHour
struct OpenHour: Codable {
    let periodList: [PeriodList]?
    let realtime: Realtime?
}

// MARK: - PeriodList
struct PeriodList: Codable {
    let periodName: String?
    let timeList: [TimeList]?
}

// MARK: - TimeList
struct TimeList: Codable {
    let timeName, timeSE, dayOfWeek: String?
}

// MARK: - Realtime
struct Realtime: Codable {
    let holiday, breaktime, realtimeOpen, moreOpenOffInfoExists: String?
    let datetime: String?
    let currentPeriod: PeriodList?
    let closedToday: String?

    enum CodingKeys: String, CodingKey {
        case holiday, breaktime
        case realtimeOpen = "open"
        case moreOpenOffInfoExists, datetime, currentPeriod, closedToday
    }
}

// MARK: - OperationInfo
struct OperationInfo: Codable {
    let appointment, delivery, pagekage: String?
}

// MARK: - PurplePhotoList
struct PurplePhotoList: Codable {
    let orgurl: String?
}

// MARK: - Comment
struct Comment: Codable {
    let placenamefull: String?
    let kamapComntcnt, scoresum, scorecnt: Int? // 총 리뷰 갯수, 총 리뷰 합
    let list: [CommentList]? // 리뷰 목록
    let hasNext: Bool?
    let reviewWriteBlocked: String? // 리뷰 작성 차단 여부 확인
}

// MARK: - CommentList
struct CommentList: Codable {
    let contents: String? // 리뷰에 적은 내용
    let point: Int? // 해당 유저가 남긴 별점
    let username: String? // 리뷰 남긴 유저 이름
    let profile: String? // 리뷰 남긴 유저 프로필
    let photoCnt: Int? // 업로드 한 사진 갯수
    let thumbnail: String? // 리뷰에 올린 썸네일 이미지
    let photoList: [FluffyPhotoList]? // 업로드한 사진 리스트 (near = true) 인 경우, 가까운 위치에서 리뷰 남긴 것.
    let userCommentCount: Int?
    let userCommentAverageScore: Double? // 해당 유저가 남긴평균 별점
    let myStorePick: Bool?
    let date: String?

    enum CodingKeys: String, CodingKey {
        case contents, point, username, profile, photoCnt, thumbnail
        case photoList, userCommentCount, userCommentAverageScore, myStorePick, date
    }
}

// MARK: - FluffyPhotoList
struct FluffyPhotoList: Codable {
    let url: String?
    let near: Bool?
}

// MARK: - MenuInfo
struct MenuInfo: Codable {
    let menucount: Int?
    let menuList: [MenuList]?
    let productyn: String?
    let menuboardphotourlList: [String]?
    let menuboardphotocount: Int?
    let timeexp: String?
}

// MARK: - MenuList
struct MenuList: Codable {
    let price: String?
    let recommend: Bool?
    let menu: String?
}

// MARK: - Photo
struct Photo: Codable {
    let photoList: [PhotoPhotoList]?
}

// MARK: - PhotoPhotoList
struct PhotoPhotoList: Codable {
    let photoCount: Int?
    let categoryName: String?
    let list: [PhotoListList]?
}

// MARK: - PhotoListList
struct PhotoListList: Codable {
    let orgurl: String?
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

class JSONCodingKey: CodingKey {
    let key: String

    required init?(intValue: Int) {
        return nil
    }

    required init?(stringValue: String) {
        key = stringValue
    }

    var intValue: Int? {
        return nil
    }

    var stringValue: String {
        return key
    }
}

class JSONAny: Codable {

    let value: Any

    static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
        return DecodingError.typeMismatch(JSONAny.self, context)
    }

    static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
        let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
        return EncodingError.invalidValue(value, context)
    }

    static func decode(from container: SingleValueDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if container.decodeNil() {
            return JSONNull()
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if let value = try? container.decodeNil() {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer() {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
        if let value = try? container.decode(Bool.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Int64.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Double.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(String.self, forKey: key) {
            return value
        }
        if let value = try? container.decodeNil(forKey: key) {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer(forKey: key) {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
        var arr: [Any] = []
        while !container.isAtEnd {
            let value = try decode(from: &container)
            arr.append(value)
        }
        return arr
    }

    static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
        var dict = [String: Any]()
        for key in container.allKeys {
            let value = try decode(from: &container, forKey: key)
            dict[key.stringValue] = value
        }
        return dict
    }

    static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
        for value in array {
            if let value = value as? Bool {
                try container.encode(value)
            } else if let value = value as? Int64 {
                try container.encode(value)
            } else if let value = value as? Double {
                try container.encode(value)
            } else if let value = value as? String {
                try container.encode(value)
            } else if value is JSONNull {
                try container.encodeNil()
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer()
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
        for (key, value) in dictionary {
            let key = JSONCodingKey(stringValue: key)!
            if let value = value as? Bool {
                try container.encode(value, forKey: key)
            } else if let value = value as? Int64 {
                try container.encode(value, forKey: key)
            } else if let value = value as? Double {
                try container.encode(value, forKey: key)
            } else if let value = value as? String {
                try container.encode(value, forKey: key)
            } else if value is JSONNull {
                try container.encodeNil(forKey: key)
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer(forKey: key)
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
        if let value = value as? Bool {
            try container.encode(value)
        } else if let value = value as? Int64 {
            try container.encode(value)
        } else if let value = value as? Double {
            try container.encode(value)
        } else if let value = value as? String {
            try container.encode(value)
        } else if value is JSONNull {
            try container.encodeNil()
        } else {
            throw encodingError(forValue: value, codingPath: container.codingPath)
        }
    }

    public required init(from decoder: Decoder) throws {
        if var arrayContainer = try? decoder.unkeyedContainer() {
            self.value = try JSONAny.decodeArray(from: &arrayContainer)
        } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
            self.value = try JSONAny.decodeDictionary(from: &container)
        } else {
            let container = try decoder.singleValueContainer()
            self.value = try JSONAny.decode(from: container)
        }
    }

    public func encode(to encoder: Encoder) throws {
        if let arr = self.value as? [Any] {
            var container = encoder.unkeyedContainer()
            try JSONAny.encode(to: &container, array: arr)
        } else if let dict = self.value as? [String: Any] {
            var container = encoder.container(keyedBy: JSONCodingKey.self)
            try JSONAny.encode(to: &container, dictionary: dict)
        } else {
            var container = encoder.singleValueContainer()
            try JSONAny.encode(to: &container, value: self.value)
        }
    }
}
