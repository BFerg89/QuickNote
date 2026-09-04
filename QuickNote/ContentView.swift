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
    private enum DictationPhase: Equatable {
        case idle
        case starting
        case recording
        case stopping
    }

    @Environment(\.modelContext) private var modelContext

    private let titles = [
        "Hold that thought!", "Write it down!", "Lock it in!",
        "Capture this!", "Drop it here!", "Quick jot!",
        "Mental note...", "Before you forget...",
        "Save for later...", "Pass it to paper...", "Notes to self..."
    ]
    @State private var currentTitle: String = ""
    @State private var selectedTab: Tabs = .home
    @State private var captureSession = CaptureSession()

    @State private var dictationService = DictationService()
    @State private var dictationPhase: DictationPhase = .idle
    @State private var dictationError: String?
    @State private var dictationStartedAt: Date = Date.now

    private var tabSelection: Binding<Tabs> {
        Binding {
            selectedTab
        } set: { requestedTab in
            if requestedTab == .dictate {
                selectedTab = .home
                startDictation()
            } else {
                selectedTab = requestedTab
            }
        }
    }
    
    var body: some View {
        TabView(selection: tabSelection) {
            Tab("Home", systemImage: "square.and.pencil", value: .home) {
                NavigationStack {
                    HomeView(session: captureSession)
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
                EmptyView()
            }
        }
        .tabViewBottomAccessory(isEnabled: dictationPhase == .recording) {
            DictationAccessory(startedAt: dictationStartedAt, stopRecording: stopDictation)
        }
    }

    private func startDictation() {
        guard dictationPhase == .idle else { return }

        dictationPhase = .starting
        dictationError = nil

        Task {
            do {
                try await dictationService.start()
                dictationStartedAt = .now
                dictationPhase = .recording
            } catch {
                dictationPhase = .idle
                dictationError = error.localizedDescription
            }
        }
    }

    private func stopDictation() {
        guard dictationPhase == .recording else { return }

        dictationPhase = .stopping

        Task {
            do {
                let transcript = try await dictationService.stop()
                captureSession.add(transcript, to: modelContext)
            } catch {
                dictationError = error.localizedDescription
            }

            dictationPhase = .idle
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Note.self, inMemory: true)
}
