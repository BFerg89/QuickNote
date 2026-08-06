//
//  Item.swift
//  QuickNote
//
//  Created by Bennett Ferguson on 2026-08-05.
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
