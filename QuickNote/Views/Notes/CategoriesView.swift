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
                            red: 104.0 / 255.0,
                            green: 112.0 / 255.0,
                            blue: 124.0 / 255.0
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
                    .fill(color.opacity(0.12))
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
