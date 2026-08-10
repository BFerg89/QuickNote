//
//  NoteRow.swift
//  QuickNote
//
//  Created by Bennett Ferguson on 2026-08-07.
//

import SwiftUI

struct NoteRow: View {
    let note: Note
    let delete: () -> Void
    
    var body: some View {
        HStack {
            Text(note.rawText)
            Spacer()
            Button(action: delete) {
                Image(systemName: "multiply")
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.circle)
        }
    }
}

#Preview {
    NoteRow(note: Note(text: "Test"), delete: {})
}
