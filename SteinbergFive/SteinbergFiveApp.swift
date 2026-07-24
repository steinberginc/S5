import SwiftUI

@main
struct SteinbergFiveApp: App {
    @StateObject private var progress = ProgressStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(progress)
                .preferredColorScheme(.dark)
        }
    }
}
