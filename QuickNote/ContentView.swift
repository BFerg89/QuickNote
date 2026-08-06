//
//  ContentView.swift
//  QuickNote
//
//  Created by Bennett Ferguson on 2026-08-05.
//

import SwiftUI

enum Tabs {
    case home, settings
}

struct ContentView: View {
    @State var selectedTab: Tabs = .home
    @State var notes: [String] = []
    @State var newNote: String = ""
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house", value: .home) {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(notes, id: \.self) { note in
                        Text(note)
                    }
                    TextField("New Note...", text: $newNote)
                        .onSubmit {
                            addNote()
                        }
                }
                .padding()
                Spacer()
            }
            
            Tab("Settings", systemImage: "gear", value: .settings) {
                Text("Settings")
            }
        }
        
    }
    
    private func addNote() {
        let trimmed = newNote.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else { return }
        
        notes.append(trimmed)
        newNote = ""
    }
}

#Preview {
    ContentView()
}
