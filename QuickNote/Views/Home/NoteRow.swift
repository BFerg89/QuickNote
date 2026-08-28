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
        switch note.category {
        case .todo:
            Color(
                red: 184.0 / 255.0,
                green: 87.0 / 255.0,
                blue: 82.0 / 255.0
            )
        case .social:
            Color(
                red: 161.0 / 255.0,
                green: 108.0 / 255.0,
                blue: 168.0 / 255.0
            )
        case .work:
            Color(
                red: 82.0 / 255.0,
                green: 131.0 / 255.0,
                blue: 177.0 / 255.0
            )
        case .admin:
            Color(
                red: 181.0 / 255.0,
                green: 139.0 / 255.0,
                blue: 79.0 / 255.0
            )
        case .misc:
            Color(
                red: 94.0 / 255.0,
                green: 151.0 / 255.0,
                blue: 119.0 / 255.0
            )
        }
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
            Spacer()

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

                    Text(note.category.rawValue)
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
                                .fill(categoryColor.opacity(0.16))
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
            note.dueDate = .now
            note.dueTime = .now
            note.category = .social
            note.processingState = .completed
            return note
        }(),
        delete: {}
    )
}
