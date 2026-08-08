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
    @Query private var notes: [Note]
    
    @State private var newNote: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            //Top Buttons
            HStack(alignment: .center) {
                Spacer()
                Button(action: nothing) {
                    Image(systemName: "checkmark")
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.circle)
            }
            
            //Notes + Input section
            ForEach(notes) { note in
                NoteRow(note: note)
            }
            TextField("New Note...", text: $newNote)
                .onSubmit {
                    addNote()
                }
        }
        .padding()
        Spacer()
    }
    
    private func addNote() {
        let trimmed = newNote.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else { return }
        
        modelContext.insert(Note(text: trimmed))
        newNote = ""
    }
    
    private func nothing() {
        
    }
}

#Preview {
    HomeView()
}
