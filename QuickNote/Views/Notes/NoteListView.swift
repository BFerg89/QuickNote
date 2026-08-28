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
    
    var body: some View {
        List(notes) { note in
            NoteRow(note: note) {
                modelContext.delete(note)
            }
        }
    }
}
