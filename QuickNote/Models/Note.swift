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
enum GeneratedNoteBody {
    case text(content: String)
    case list(items: [String])
}

@Generable
struct GeneratedDueTime {
    @Guide(
        description: "Hour using 24-hour time, from 0 through 23.",
        .range(0...23)
    )
    var hour: Int

    @Guide(
        description: "Minute from 0 through 59.",
        .range(0...59)
    )
    var minute: Int
}

@Generable
struct GeneratedDueDate {
    var year: Int

    @Guide(
        description: "Month number from 1 through 12.",
        .range(1...12)
    )
    var month: Int

    @Guide(
        description: "Day number from 1 through 31.",
        .range(1...31)
    )
    var day: Int

    @Guide(
        description: "The resolved local time when the note includes a time. Otherwise return nil."
    )
    var time: GeneratedDueTime?
}

@Generable
struct GeneratedNote {
    var title: String?

    @Guide(
        description: "Use list for a sequence of items, including comma-separated items. Put exactly one item in each array element. Otherwise use text."
    )
    var body: GeneratedNoteBody

    @Guide(
        description: "The resolved due date when the note contains explicit or relative date language. Otherwise return nil."
    )
    var dueDate: GeneratedDueDate?

    var category: NoteCategory
}

@Model
class Note {
    var rawText: String
    
    var processingState: ProcessingState
    var processedText: String?
    var title: String?
    var dueDate: Date?
    var dueTime: Date?
    
    var category: NoteCategory
    
    var createdAt: Date
    
    init(text: String) {
        self.rawText = text
        self.processingState = ProcessingState.pending
        self.category = NoteCategory.misc
        self.createdAt = Date()
    }
}
