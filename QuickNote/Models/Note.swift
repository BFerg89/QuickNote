//
//  Note.swift
//  QuickNote
//
//  Created by Bennett Ferguson on 2026-08-07.
//

import Foundation
import SwiftData

enum NoteCategory: String, Codable, CaseIterable {
    case todo
    case social
    case work
    case admin
    case misc
}

@Model
class Note {
    var rawText: String
    
    var isProcessed: Bool
    var processedText: String
    var title: String
    
    var category: NoteCategory
    
    var createdAt: Date
    
    init(text: String) {
        self.rawText = text
        self.isProcessed = false
        self.processedText = ""
        self.title = ""
        self.category = NoteCategory.misc
        self.createdAt = Date()
    }
}
