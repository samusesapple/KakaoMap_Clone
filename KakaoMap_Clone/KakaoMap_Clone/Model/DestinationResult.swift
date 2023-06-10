//
//  DestinationResult.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/28.
//


import Foundation

// MARK: - DestinationResult
struct DestinationResult: Codable {
    let transID: String?
    let routes: [Route]?

    enum CodingKeys: String, CodingKey {
        case transID = "trans_id"
        case routes
    }
}

// MARK: - Route
struct Route: Codable {
    let resultCode: Int?
    let resultMsg: String?
    let summary: Summary?
    let sections: [Section]?

    enum CodingKeys: String, CodingKey {
        case resultCode = "result_code"
        case resultMsg = "result_msg"
        case summary, sections
    }
}

// MARK: - Section
struct Section: Codable {
    let distance, duration: Int?
    let bound: Bound?
    let roads: [Road]?
    let guides: [Guide]?
}

// MARK: - Bound
struct Bound: Codable {
    let minX, minY, maxX, maxY: Double?

    enum CodingKeys: String, CodingKey {
        case minX = "min_x"
        case minY = "min_y"
        case maxX = "max_x"
        case maxY = "max_y"
    }
}

// MARK: - Guide
struct Guide: Codable {
    let name: String?
    let x, y: Double?
    let distance, duration, type: Int?
    let guidance: String?
    let roadIndex: Int?

    enum CodingKeys: String, CodingKey {
        case name, x, y, distance, duration, type, guidance
        case roadIndex = "road_index"
    }
}

// MARK: - Road
struct Road: Codable {
    let name: String?
    let distance, duration, trafficSpeed, trafficState: Int?
    let vertexes: [Double]?

    enum CodingKeys: String, CodingKey {
        case name, distance, duration
        case trafficSpeed = "traffic_speed"
        case trafficState = "traffic_state"
        case vertexes
    }
}

// MARK: - Summary
struct Summary: Codable {
    let origin, destination: Destination?
    let waypoints: [JSONAny]?
    let priority: String?
    let bound: Bound?
    let distance, duration: Int?
}

// MARK: - Destination
struct Destination: Codable {
    let name: String?
    let x, y: Double?
}

