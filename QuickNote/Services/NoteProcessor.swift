//
//  NoteProcessor.swift
//  QuickNote
//
//  Created by Bennett Ferguson on 2026-08-11.
//

import Foundation
import SwiftData

enum NoteProcessor {
    @MainActor
    static func process(_ note: Note) async {
        guard !note.isDeleted,
              note.processingState == .pending else {
            return
        }
        
        note.processingState = .processing
        
        do {
            let generated = try await NoteGenerator.generate(from: note.rawText)

            guard !note.isDeleted else { return }
            
            note.title = generated.title
            let resolvedDueDate = date(from: generated.dueDate)
            note.dueDate = resolvedDueDate?.date
            note.dueTime = resolvedDueDate?.time

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
            guard !note.isDeleted else { return }

            note.processingState = .failed
            print("Note processing failed: \(error)")
        }
    }

    private static func date(
        from generatedDate: GeneratedDueDate?
    ) -> (date: Date, time: Date?)? {
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

        guard let generatedTime = generatedDate.time else {
            return (date, nil)
        }

        components.hour = generatedTime.hour
        components.minute = generatedTime.minute

        guard let dateWithTime = calendar.date(from: components) else {
            return (date, nil)
        }

        let resolvedTimeComponents = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: dateWithTime
        )

        guard resolvedTimeComponents.year == generatedDate.year,
              resolvedTimeComponents.month == generatedDate.month,
              resolvedTimeComponents.day == generatedDate.day,
              resolvedTimeComponents.hour == generatedTime.hour,
              resolvedTimeComponents.minute == generatedTime.minute else {
            return (date, nil)
        }

        return (date, dateWithTime)
    }
}
