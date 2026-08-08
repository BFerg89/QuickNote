//
//  Note.swift
//  QuickNote
//
//  Created by Bennett Ferguson on 2026-08-07.
//

import Foundation
import SwiftData

@Model
class Note {
    var text: String
    var createdAt: Date
    
    init(text: String) {
        self.text = text
        self.createdAt = Date()
    }
}
