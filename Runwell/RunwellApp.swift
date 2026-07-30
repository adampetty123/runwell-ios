import SwiftUI

@main
struct RunwellApp: App {
    @StateObject private var session = Session()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
                .preferredColorScheme(.dark)
                .tint(Theme.accent)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var session: Session

    var body: some View {
        Group {
            if session.isAuthenticated {
                DashboardView()
            } else {
                AuthView()
            }
        }
        .background(Theme.bg.ignoresSafeArea())
        .task { await session.restore() }
    }
}
