//
//  NoteRow.swift
//  QuickNote
//
//  Created by Bennett Ferguson on 2026-08-07.
//

import SwiftUI
import Foundation

private struct ArcSpinner: View {
    @State private var isRotating = false

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.28)
            .stroke(
                .secondary,
                style: StrokeStyle(
                    lineWidth: 2.25,
                    lineCap: .round
                )
            )
            .frame(width: 16, height: 16)
            .rotationEffect(.degrees(isRotating ? 360 : 0))
            .animation(
                .linear(duration: 0.75)
                    .repeatForever(autoreverses: false),
                value: isRotating
            )
            .onAppear {
                isRotating = true
            }
            .accessibilityLabel("Organizing note")
    }
}

struct NoteRow: View {
    let note: Note
    let delete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if let title = note.title, !title.isEmpty {
                    Text(title)
                        .font(.headline)
                }
                
                Text(note.processedText ?? note.rawText)
            }
            Spacer()
            if note.processingState == .processing {
                ArcSpinner()
            } else if let dueDate = note.dueDate {
                VStack(alignment: .center, spacing: 2) {
                    Text(dueDate.formatted(.dateTime.weekday(.wide)))

                    Text(
                        dueDate.formatted(
                            .dateTime.month(.abbreviated).day().year()
                        )
                    )
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NoteRow(
        note: {
            let note = Note(text: "Test")
            note.dueDate = .now
            return note
        }(),
        delete: {}
    )
}
