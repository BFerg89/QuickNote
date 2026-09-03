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

    let session: CaptureSession

    @State private var newNote: String = ""
    @FocusState private var isNewNoteFocused: Bool

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
                ForEach(session.visibleNotes) { note in
                    NoteRow(note: note, delete: {
                        session.remove(note, from: modelContext)
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
        if session.add(newNote, to: modelContext) {
            newNote = ""
        }
    }

    private func regenerate(note: Note) {
        Task {
            await NoteProcessor.retry(note)
        }
    }
}

#Preview {
    HomeView(session: CaptureSession())
        .modelContainer(for: Note.self, inMemory: true)
}
