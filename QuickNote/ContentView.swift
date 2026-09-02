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
            HStack {
                Text("0:28") //Placeholder for elapsed time
                Spacer()
                VStack {
                    Image(systemName: "waveform") //Placeholder for live waveform
                    Text("Call john tommorrow") //Placeholder for transcriptions
                        .font(.caption)
                        .foregroundStyle(Color("NoteText"))
                        .opacity(0.75)
                }
                Spacer()
                Button {
                    isRecording = false
                    selectedTab = .home
                } label: {
                    Label("Stop Recording", systemImage: "stop.circle")
                }
                .foregroundStyle(.red)
                .labelStyle(.iconOnly)
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Note.self, inMemory: true)
}
