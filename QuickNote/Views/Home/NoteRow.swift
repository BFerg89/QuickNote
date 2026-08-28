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
    let regenerate: (() -> Void)?

    init(
        note: Note,
        delete: @escaping () -> Void,
        regenerate: (() -> Void)? = nil
    ) {
        self.note = note
        self.delete = delete
        self.regenerate = regenerate
    }

    private var categoryColor: Color {
        note.category.color
    }
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                if let title = note.title, !title.isEmpty {
                    Text(title)
                        .font(.headline)
                }
                
                Text(note.processedText ?? note.rawText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let dueDate = note.dueDate {
                VStack(alignment: .center, spacing: 2) {
                    if let dueTime = note.dueTime {
                        Text(
                            "\(dueDate.formatted(.dateTime.weekday(.wide))), \(dueTime.formatted(.dateTime.hour().minute()))"
                        )
                    } else {
                        Text(dueDate.formatted(.dateTime.weekday(.wide)))
                    }

                    Text(
                        dueDate.formatted(
                            .dateTime.month(.abbreviated).day().year()
                        )
                    )
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
            }

            if note.processingState == .processing {
                ArcSpinner()
            } else if note.processingState == .completed {
                HStack(spacing: 5) {
                    Circle()
                        .fill(categoryColor)
                        .frame(width: 5, height: 5)

                    Text(note.category.displayTitle)
                        .foregroundStyle(.primary)
                }
                .font(.caption2.weight(.semibold))
                .lineLimit(1)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background {
                    Capsule()
                        .fill(.thinMaterial)
                        .overlay {
                            Capsule()
                                .fill(
                                    categoryColor.opacity(
                                        QuickNoteStyle.categoryTintOpacity
                                    )
                                )
                        }
                        .overlay {
                            Capsule()
                                .stroke(
                                    .white.opacity(0.22),
                                    lineWidth: 0.75
                                )
                        }
                        .shadow(
                            color: .black.opacity(0.06),
                            radius: 4,
                            x: 0,
                            y: 2
                        )
                }
            } else if note.processingState == .failed {
                HStack(spacing: 5) {
                    Image(systemName: "exclamationmark.circle.fill")
                    Text("Processing failed")
                }
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.red)
                .lineLimit(1)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(.red.opacity(0.1), in: Capsule())
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive, action: delete) {
                Image(systemName: "trash")
            }
            .accessibilityLabel("Delete")
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            if let regenerate {
                Button(action: regenerate) {
                    Image(systemName: "arrow.clockwise")
                }
                .tint(categoryColor)
                .accessibilityLabel("Regenerate")
            }
        }
    }
}

#Preview {
    NoteRow(
        note: {
            let note = Note(text: "Test")
            note.category = .social
            note.processingState = .completed
            note.dueDate = .now
            note.dueTime = .now
            return note
        }(),
        delete: {}
    )
}
