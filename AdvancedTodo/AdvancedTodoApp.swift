// Advanced ToDo – COMP3097 Group G9

import SwiftUI

@main
struct AdvancedTodoApp: App {
    @State private var showLaunch = true
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            if showLaunch {
                LaunchView(showLaunch: $showLaunch)
            } else {
                HomeView()
                    .environmentObject(appState)
            }
        }
    }
}
