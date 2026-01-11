//
//  Item.swift
//  CareAhead
//
//  Created by Jonathan Zhou on 2026-01-10.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
