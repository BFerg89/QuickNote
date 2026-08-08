//
//  ContentView.swift
//  QuickNote
//
//  Created by Bennett Ferguson on 2026-08-05.
//

import SwiftUI

enum Tabs {
    case home, notes
}

struct ContentView: View {
    @State var selectedTab: Tabs = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "square.and.pencil", value: .home) {
                HomeView()
            }
            
            Tab("Notes", systemImage: "folder", value: .notes) {
                Text("Notes")
            }
        }
        
    }
}

#Preview {
    ContentView()
}
