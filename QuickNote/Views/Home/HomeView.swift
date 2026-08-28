//
//  HomeView.swift
//  QuickNote
//
//  Created by Bennett Ferguson on 2026-08-06.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var sessionNotes: [Note] = []
    @State private var newNote: String = ""
    @FocusState private var isNewNoteFocused: Bool
    
    var body: some View {
        ZStack {
            Image("paper-texture")
                .resizable(resizingMode: .tile)
                .opacity(0.25)
                .ignoresSafeArea()
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        //Notes + Input section
                        ForEach(sessionNotes) { note in
                            NoteRow(note: note, delete: {
                                sessionNotes.removeAll { $0 === note }
                                modelContext.delete(note)
                            })
                        }
                        TextField("New Note...", text: $newNote)
                            .focused($isNewNoteFocused)
                            .onSubmit {
                                addNote()
                            }
                        Spacer(minLength: 0)
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                isNewNoteFocused = true
                            }
                    }
                    .padding()
                    .frame(
                        minHeight: geometry.size.height,
                        alignment: .top
                    )
                }
                .contentMargins(.bottom, 40, for: .scrollContent)
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
}

#Preview {
    HomeView()
        .modelContainer(for: Note.self, inMemory: true)
}
