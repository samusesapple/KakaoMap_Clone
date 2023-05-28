//
//  MeasureFormatter.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/28.
//

import Foundation

struct MeasureFormatter {
    
    static func measureDistance(distance: String) -> String {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = .medium
        formatter.numberFormatter.maximumFractionDigits = 1
        
        if distance.count > 3 {
            let doubleDistance = Double(distance)!
            let measurement = Measurement(value: doubleDistance, unit: UnitLength.meters).converted(to: .kilometers)
            
            return formatter.string(from: measurement)
        } else {
            return distance + "m"
        }
    }
    
}
