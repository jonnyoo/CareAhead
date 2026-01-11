import Foundation
import SwiftData

@Model
final class VitalSign {
    var timestamp: Date
    var heartRate: Int
    var breathingRate: Int
    var notes: String?
    
    init(heartRate: Int, breathingRate: Int, notes: String? = nil) {
        self.timestamp = Date()
        self.heartRate = heartRate
        self.breathingRate = breathingRate
        self.notes = notes
    }
}//
//  VitalSign.swift
//  CareAhead
//
//  Created by Michele Mazzetti on 2026-01-11.
//

