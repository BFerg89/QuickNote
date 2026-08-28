//
//  NotesView.swift
//  QuickNote
//
//  Created by Bennett Ferguson on 2026-08-09.
//

import SwiftUI

struct CategoriesView: View {
    private let spacing: CGFloat = 16
    private let gridHorizontalSpacing: CGFloat = 12
    private let maximumCardHeight: CGFloat = 140

    private var columns: [GridItem] {
        [
            GridItem(.flexible(), spacing: gridHorizontalSpacing),
            GridItem(.flexible())
        ]
    }

    private let gridCategories: [NoteCategory] = [
        .social,
        .work,
        .admin,
        .misc
    ]

    var body: some View {
        ZStack {
            QuickNotePaperBackground()

            GeometryReader { geometry in
                let availableWideCardHeight = (
                    geometry.size.height - (spacing * 5)
                ) / 4
                let wideCardHeight = max(
                    0,
                    min(maximumCardHeight, availableWideCardHeight)
                )
                let availableGridHeight = (
                    geometry.size.height
                        - (spacing * 5)
                        - (wideCardHeight * 2)
                ) / 2
                let gridColumnWidth = (
                    geometry.size.width
                        - (spacing * 2)
                        - gridHorizontalSpacing
                ) / 2
                let gridCardHeight = max(
                    0,
                    min(gridColumnWidth, availableGridHeight)
                )

                VStack(spacing: spacing) {
                    categoryCard(for: .todo)
                        .frame(height: wideCardHeight)

                    LazyVGrid(columns: columns, spacing: spacing) {
                        ForEach(gridCategories, id: \.rawValue) { category in
                            categoryCard(for: category)
                                .frame(height: gridCardHeight)
                        }
                    }

                    NavigationLink {
                        NoteListView(category: nil)
                    } label: {
                        noteCard(
                            title: "All Notes",
                            systemImage: "square.stack.3d.up.fill",
                            color: QuickNoteStyle.allNotesColor
                        )
                    }
                    .buttonStyle(.plain)
                    .frame(height: wideCardHeight)
                }
                .padding(spacing)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .center
                )
            }
        }
    }

    private func categoryCard(for category: NoteCategory) -> some View {
        NavigationLink {
            NoteListView(category: category)
        } label: {
            noteCard(
                title: category.displayTitle,
                systemImage: category.systemImage,
                color: category.color
            )
        }
        .buttonStyle(.plain)
    }

    private func noteCard(title: String, systemImage: String, color: Color) -> some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(.thinMaterial)
            .frame(maxWidth: .infinity)
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        color.opacity(QuickNoteStyle.categoryTintOpacity)
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(.white.opacity(0.22), lineWidth: 0.75)
            }
            .shadow(
                color: .black.opacity(0.06),
                radius: 10,
                x: 0,
                y: 4
            )
            .overlay {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Image(systemName: systemImage)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(color)
                            .frame(width: 36, height: 36, alignment: .leading)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                    
                    Spacer()
                    
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .padding(16)
            }
    }
    
}

#Preview {
    CategoriesView()
}
