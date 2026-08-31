//
//  SettingsView.swift
//  QuickNote
//
//  Created by Bennett Ferguson on 2026-08-29.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("notifications_enabled") private var notifications = false
    @AppStorage("app_theme") private var selectedTheme: AppTheme = .system

    private var notificationBinding: Binding<Bool> {
        Binding {
            notifications
        } set: { isEnabled in
            guard isEnabled else {
                notifications = false
                return
            }

            Task { @MainActor in
                notifications = await NotificationManager.manager.requestAuthorization()
            }
        }
    }
    
    var body: some View {
        List {
            Section("Functionality") {
                Toggle(isOn: notificationBinding) {
                    Text("Notifications")
                        .fontWeight(.medium)
                }
            }
            
            Section("Theme") {
                Picker("Theme", selection: $selectedTheme) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(theme.rawValue).tag(theme)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .task {
            if notifications, !(await NotificationManager.manager.isAuthorized()) {
                notifications = false
            }
        }
    }
}

#Preview {
    SettingsView()
}
