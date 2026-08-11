//
//  Note.swift
//  QuickNote
//
//  Created by Bennett Ferguson on 2026-08-07.
//

import Foundation
import SwiftData
import FoundationModels

@Generable
enum NoteCategory: String, Codable, CaseIterable {
    case todo
    case social
    case work
    case admin
    case misc
}

enum ProcessingState: String, Codable {
    case pending
    case processing
    case completed
    case failed
}

@Generable
struct GeneratedNote {
    var title: String?
    var processedText: String
    var category: NoteCategory
}

@Model
class Note {
    var rawText: String
    
    var processingState: ProcessingState
    var processedText: String?
    var title: String?
    
    var category: NoteCategory
    
    var createdAt: Date
    
    init(text: String) {
        self.rawText = text
        self.processingState = ProcessingState.pending
        self.category = NoteCategory.misc
        self.createdAt = Date()
    }
}
