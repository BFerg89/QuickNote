//
//  NoteProcessor.swift
//  QuickNote
//
//  Created by Bennett Ferguson on 2026-08-11.
//

import Foundation
import FoundationModels

enum NoteProcessor {
    @MainActor
    static func process(_ note: Note) async {
        guard note.processingState == .pending else { return }
        
        note.processingState = .processing
        
        do {
            let generated: GeneratedNote
            
            if FoundationProcessor.isAvailable {
                generated = try await FoundationProcessor.process(note.rawText)
            } else {
                //Strictly placeholder
                generated = try await FoundationProcessor.process(note.rawText)
                //Replace with ExternalProcessor
            }
            
            note.title = generated.title
            note.dueDate = date(from: generated.dueDate)

            switch generated.body {
            case .text(let content):
                note.processedText = content
            case .list(let items):
                note.processedText = items
                    .map { "- \($0)" }
                    .joined(separator: "\n")
            }

            note.category = generated.category
            note.processingState = .completed
        } catch {
            note.processingState = .failed
            print("Note processing failed: \(error)")
        }
    }

    private static func date(from generatedDate: GeneratedDueDate?) -> Date? {
        guard let generatedDate else { return nil }

        var calendar = Calendar.current
        calendar.timeZone = .current

        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = calendar.timeZone
        components.year = generatedDate.year
        components.month = generatedDate.month
        components.day = generatedDate.day

        guard let date = calendar.date(from: components) else { return nil }

        let resolvedComponents = calendar.dateComponents(
            [.year, .month, .day],
            from: date
        )

        guard resolvedComponents.year == generatedDate.year,
              resolvedComponents.month == generatedDate.month,
              resolvedComponents.day == generatedDate.day else {
            return nil
        }

        return date
    }
}
