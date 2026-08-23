//
//  NotesView.swift
//  QuickNote
//
//  Created by Bennett Ferguson on 2026-08-09.
//

import SwiftUI

struct CategoriesView: View {
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

                NavigationLink {
                    NoteListView(category: nil)
                        .navigationTitle("All Notes")
                } label: {
                    noteCard(
                        title: "All Notes",
                        systemImage: "square.stack.3d.up.fill",
                        color: Color(
                            red: 142.0 / 255.0,
                            green: 142.0 / 255.0,
                            blue: 147.0 / 255.0
                        )
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

    private func categoryCard(for category: NoteCategory) -> some View {
        NavigationLink {
            NoteListView(category: category)
                .navigationTitle(title(for: category))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(title(for: category))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .glassEffect(.regular, in: Capsule())
                    }
                }
        } label: {
            noteCard(
                title: title(for: category),
                systemImage: icon(for: category),
                color: color(for: category)
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
                    .fill(color.opacity(0.5))
            }
            .shadow(
                color: color.opacity(0.12),
                radius: 12,
                x: 0,
                y: 6
            )
            .overlay {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(color.opacity(0.25))
                                .stroke(color.opacity(0.15), lineWidth: 1)
                            Image(systemName: systemImage)
                        }
                        .frame(width: 36, height: 36)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    
                    Spacer()
                    
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .padding(16)
            }
    }
    
    private func icon(for category: NoteCategory) -> String {
        switch category {
        case .todo:
            "checkmark"
        case .social:
            "person.2.fill"
        case .work:
            "briefcase.fill"
        case .admin:
            "folder.fill"
        case .misc:
            "square.grid.2x2.fill"
        }
    }

    private func color(for category: NoteCategory) -> Color {
        switch category {
        case .todo:
            Color(
                red: 255.0 / 255.0,
                green: 69.0 / 255.0,
                blue: 58.0 / 255.0
            )
        case .social:
            Color(
                red: 191.0 / 255.0,
                green: 90.0 / 255.0,
                blue: 242.0 / 255.0
            )
        case .work:
            Color(
                red: 10.0 / 255.0,
                green: 132.0 / 255.0,
                blue: 255.0 / 255.0
            )
        case .admin:
            Color(
                red: 255.0 / 255.0,
                green: 159.0 / 255.0,
                blue: 10.0 / 255.0
            )
        case .misc:
            Color(
                red: 48.0 / 255.0,
                green: 209.0 / 255.0,
                blue: 88.0 / 255.0
            )
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
    CategoriesView()
}
