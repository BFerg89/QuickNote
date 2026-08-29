//
//  HomeView.swift
//  QuickNote
//
//  Created by Bennett Ferguson on 2026-08-06.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    
    @State private var sessionNotes: [Note] = []
    @State private var newNote: String = ""
    @FocusState private var isNewNoteFocused: Bool

    private var visibleSessionNotes: [Note] {
        sessionNotes.filter { !$0.isDeleted }
    }

    private var captureTextColor: Color {
        if colorScheme == .dark {
            Color(
                red: 227.0 / 255.0,
                green: 218.0 / 255.0,
                blue: 201.0 / 255.0
            )
        } else {
            Color("NoteText")
        }
    }
    
    var body: some View {
        ZStack {
            QuickNotePaperBackground()

            List {
                ForEach(visibleSessionNotes) { note in
                    NoteRow(note: note, delete: {
                        sessionNotes.removeAll { $0 === note }
                        modelContext.delete(note)
                    }, regenerate: {
                        regenerate(note: note)
                    })
                    .quickNoteListRowStyle()
                }

                TextField("New Note...", text: $newNote)
                    .focused($isNewNoteFocused)
                    .tint(Color.accentColor)
                    .foregroundStyle(captureTextColor)
                    .onSubmit {
                        addNote()
                    }
                    .quickNoteListRowStyle()
            }
            .quickNoteListStyle()
            .onTapGesture {
                isNewNoteFocused = true
            }
        }
    }
    
    private func addNote() {
        let trimmed = newNote.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else { return }
        
        let note = Note(text: trimmed)
        modelContext.insert(note)
        sessionNotes.append(note)
        newNote = ""

        Task {
            await NoteProcessor.process(note)
        }
    }

    private func regenerate(note: Note) {
        Task {
            await NoteProcessor.retry(note)
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Note.self, inMemory: true)
}
