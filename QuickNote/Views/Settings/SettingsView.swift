//
//  SettingsView.swift
//  QuickNote
//
//  Created by Bennett Ferguson on 2026-08-29.
//

import SwiftUI

struct SettingsView: View {
    @State var notifications = false
    @State var selectedAppearance: Appearance = .system
    
    enum Appearance: String, CaseIterable, Identifiable {
        case light = "Light"
        case dark = "Dark"
        case system = "System"
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        List {
            Section("Functionality") {
                Toggle(isOn: $notifications) {
                    Text("Notifications")
                        .fontWeight(.medium)
                }
            }
            .foregroundStyle(Color("NoteText"))
            
            Section("Appearance") {
                Picker("Appearance", selection: $selectedAppearance) {
                    ForEach(Appearance.allCases) { theme in
                        Text(theme.rawValue).tag(theme)
                    }
                }
                .pickerStyle(.segmented)
            }
            .foregroundStyle(Color("NoteText"))
        }
    }
}

#Preview {
    SettingsView()
}
