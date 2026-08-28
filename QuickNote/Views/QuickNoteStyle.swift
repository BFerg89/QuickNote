//
//  QuickNoteStyle.swift
//  QuickNote
//

import SwiftUI

enum QuickNoteStyle {
    static let categoryTintOpacity = 0.12

    static let allNotesColor = Color(
        red: 104.0 / 255.0,
        green: 112.0 / 255.0,
        blue: 124.0 / 255.0
    )
}

extension NoteCategory {
    var displayTitle: String {
        switch self {
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

    var systemImage: String {
        switch self {
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

    var color: Color {
        switch self {
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
}

struct QuickNotePaperBackground: View {
    var body: some View {
        Image("paper-texture")
            .resizable(resizingMode: .tile)
            .opacity(0.25)
            .ignoresSafeArea()
    }
}

private struct QuickNoteListModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .contentMargins(.bottom, 40, for: .scrollContent)
    }
}

private struct QuickNoteListRowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowInsets(
                EdgeInsets(
                    top: 10,
                    leading: 16,
                    bottom: 10,
                    trailing: 16
                )
            )
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }
}

private struct QuickNoteNavigationTitleModifier: ViewModifier {
    let title: String

    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .glassEffect(.regular, in: Capsule())
                }
            }
    }
}

extension View {
    func quickNoteListStyle() -> some View {
        modifier(QuickNoteListModifier())
    }

    func quickNoteListRowStyle() -> some View {
        modifier(QuickNoteListRowModifier())
    }

    func quickNoteNavigationTitle(_ title: String) -> some View {
        modifier(QuickNoteNavigationTitleModifier(title: title))
    }
}
