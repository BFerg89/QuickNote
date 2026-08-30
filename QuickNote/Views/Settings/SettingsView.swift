//
//  SettingsView.swift
//  QuickNote
//
//  Created by Bennett Ferguson on 2026-08-29.
//

import SwiftUI

struct SettingsView: View {
    @State var notifications = false
    @AppStorage("app_theme") private var selectedTheme: AppTheme = .system
    
    var body: some View {
        List {
            Section("Functionality") {
                Toggle(isOn: $notifications) {
                    Text("Notifications")
                        .fontWeight(.medium)
                }
            }
            .foregroundStyle(Color("NoteText"))
            
            Section("Theme") {
                Picker("Theme", selection: $selectedTheme) {
                    ForEach(AppTheme.allCases) { theme in
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
