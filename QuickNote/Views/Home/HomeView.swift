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
    @Query(sort: [SortDescriptor(\Note.createdAt, order: .forward)]) private var notes: [Note]
    
    @State private var newNote: String = ""
    @FocusState private var isNewNoteFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            //Top Buttons
            HStack(alignment: .center) {
                Spacer()
                Button(action: {}) {
                    Image(systemName: "checkmark")
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.circle)
            }
            
            //Notes + Input section
            ForEach(notes) { note in
                NoteRow(note: note, delete: {
                    modelContext.delete(note)
                })
            }
            TextField("New Note...", text: $newNote)
                .focused($isNewNoteFocused)
                .onSubmit {
                    addNote()
                }
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    isNewNoteFocused = true
                }
        }
        .padding()
    }
    
    private func addNote() {
        let trimmed = newNote.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else { return }
        
        let note = Note(text: trimmed)
        modelContext.insert(note)
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
