//
//  NotesView.swift
//  QuickNote
//
//  Created by Bennett Ferguson on 2026-08-09.
//

import SwiftUI

struct NotesView: View {
    private let spacing: CGFloat = 16
    private let maximumCardHeight: CGFloat = 140

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    private let gridCategories: [NoteCategory] = [
        .social,
        .work,
        .admin,
        .misc
    ]

    var body: some View {
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
            let availableGridWidth = (
                geometry.size.width - (spacing * 3)
            ) / 2
            let gridCardSize = max(
                0,
                min(availableGridWidth, availableGridHeight)
            )

            VStack(spacing: spacing) {
                categoryCard(for: .todo)
                    .frame(height: wideCardHeight)

                LazyVGrid(columns: columns, spacing: spacing) {
                    ForEach(gridCategories, id: \.rawValue) { category in
                        categoryCard(for: category)
                            .frame(width: gridCardSize, height: gridCardSize)
                    }
                }

                noteCard(title: "All Notes")
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

    private func categoryCard(for category: NoteCategory) -> some View {
        noteCard(title: title(for: category))
    }

    private func noteCard(title: String) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.blue.opacity(0.5))
            .frame(maxWidth: .infinity)
            .overlay {
                Text(title)
            }
    }

    private func title(for category: NoteCategory) -> String {
        switch category {
        case .todo:
            "To-Do"
        case .social:
            "Social"
        case .work:
            "Work"
        case .admin:
            "Admin"
        case .misc:
            "Misc"
        }
    }
}

#Preview {
    NotesView()
}
