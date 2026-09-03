//
//  CaptureSession.swift
//  QuickNote
//

import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class CaptureSession {
    private(set) var notes: [Note] = []

    var visibleNotes: [Note] {
        notes.filter { !$0.isDeleted }
    }

    @discardableResult
    func add(_ text: String, to modelContext: ModelContext) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else { return false }

        let note = Note(text: trimmed)
        modelContext.insert(note)
        notes.append(note)

        Task {
            await NoteProcessor.process(note)
        }

        return true
    }

    func remove(_ note: Note, from modelContext: ModelContext) {
        notes.removeAll { $0 === note }
        NotificationManager.manager.cancelPendingNotification(note: note)
        modelContext.delete(note)
    }
}
