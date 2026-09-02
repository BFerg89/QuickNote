//
//  ContentView.swift
//  QuickNote
//
//  Created by Bennett Ferguson on 2026-08-05.
//

import SwiftUI
import SwiftData

enum Tabs {
    case home, notes, settings, dictate
}

struct ContentView: View {
    private let titles = [
        "Hold that thought!", "Write it down!", "Lock it in!",
        "Capture this!", "Drop it here!", "Quick jot!",
        "Mental note...", "Before you forget...",
        "Save for later...", "Pass it to paper...", "Notes to self..."
    ]
    @State var currentTitle: String = ""
    @State var isRecording: Bool = false
    @State var selectedTab: Tabs = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "square.and.pencil", value: .home) {
                NavigationStack {
                    HomeView()
                        .quickNoteNavigationTitle(currentTitle)
                }
                .onAppear {
                    currentTitle = titles.randomElement() ?? "Quick Note"
                }
            }
            
            Tab("Notes", systemImage: "folder", value: .notes) {
                NavigationStack {
                    CategoriesView()
                        .quickNoteNavigationTitle("Notes")
                }
            }
            
            Tab("Settings", systemImage: "gear", value: .settings) {
                NavigationStack {
                    SettingsView()
                        .quickNoteNavigationTitle("Settings")
                }
            }
            
            Tab("Dictate", systemImage: "microphone", value: .dictate, role: .search) {
                NavigationStack {
                    HomeView()
                        .quickNoteNavigationTitle(currentTitle)
                }
                .onAppear() {
                    isRecording = true
                }
            }
        }
        .tabViewBottomAccessory(isEnabled: isRecording) {
            DictationAccessory {
                isRecording = false
                selectedTab = .home
            }
        }
    }
}

private struct DictationAccessory: View {
    @Environment(\.tabViewBottomAccessoryPlacement) private var placement

    let stopRecording: () -> Void

    private var isInline: Bool {
        placement == .inline
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "waveform")
                .font(.system(size: isInline ? 15 : 17, weight: .semibold))
                .foregroundStyle(.red)
                .frame(width: isInline ? 28 : 34, height: isInline ? 28 : 34)
                .background(.red.opacity(0.12), in: Circle())
                .accessibilityHidden(true)

            if isInline {
                Text("Recording · 0:28") // Placeholder for recording state and elapsed time
                    .font(.caption.weight(.semibold))
                    .monospacedDigit()
                    .lineLimit(1)
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 5) {
                        Text("Listening")
                            .fontWeight(.semibold)

                        Text("·")
                            .foregroundStyle(.tertiary)

                        Text("0:28") // Placeholder for elapsed time
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                    .font(.caption)

                    Text("Call John tomorrow") // Placeholder for live transcription
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .accessibilityElement(children: .combine)
            }

            Spacer(minLength: 4)

            Button(action: stopRecording) {
                Image(systemName: "stop.circle.fill")
                    .font(.system(size: isInline ? 26 : 30, weight: .semibold))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .red)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Stop recording")
        }
        .padding(.leading, isInline ? 8 : 12)
        .padding(.trailing, 8)
        .padding(.vertical, isInline ? 2 : 6)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Note.self, inMemory: true)
}
