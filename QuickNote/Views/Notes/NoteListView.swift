//
//  NoteListView.swift
//  QuickNote
//
//  Created by Bennett Ferguson on 2026-08-11.
//

import SwiftUI
import SwiftData

struct NoteListView: View {
    @Environment(\.modelContext) private var modelContext

    let category: NoteCategory?
    
    @Query(
        sort: [SortDescriptor(\Note.createdAt, order: .reverse)]
    )
    private var allNotes: [Note]
    
    private var notes: [Note] {
        guard let category else {
            return allNotes
        }
        
        return allNotes.filter { note in
            note.category == category
        }
    }

    private var title: String {
        category?.displayTitle ?? "All Notes"
    }
    
    var body: some View {
        ZStack {
            QuickNotePaperBackground()

            List(notes) { note in
                NoteRow(note: note, delete: {
                    NotificationManager.manager.cancelPendingNotification(note: note)
                    modelContext.delete(note)
                }, regenerate: {
                    regenerate(note: note)
                })
                .quickNoteListRowStyle()
            }
            .quickNoteListStyle()
        }
        .quickNoteNavigationTitle(title)
    }

    private func regenerate(note: Note) {
        Task {
            await NoteProcessor.retry(note)
        }
    }
}
