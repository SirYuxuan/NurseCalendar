//
//  Item.swift
//  Nurse Calendar
//
//  Created by 雨轩 on 2024/12/26.
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
