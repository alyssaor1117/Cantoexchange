import SwiftUI

struct MainTabView: View {
    @Environment(AppSessionStore.self) private var store
    @State private var selectedTab: Tab = .discover

    enum Tab: Hashable {
        case discover
        case sessions
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                MatchingDashboardView()
            }
            .tabItem {
                Label(store.activePerspective == .learner ? "Discover" : "Mentor", systemImage: "person.2.badge.gearshape")
            }
            .tag(Tab.discover)

            NavigationStack {
                SessionsOverviewView()
            }
            .tabItem {
                Label("Sessions", systemImage: "calendar")
            }
            .badge(store.upcomingMeetings.count)
            .tag(Tab.sessions)
        }
        .tint(BrandTheme.jade)
        .overlay(alignment: .top) {
            BannerToastOverlay()
        }
    }
}

struct ContentView: View {
    @State private var store: AppSessionStore

    init(store: AppSessionStore = AppSessionStore()) {
        _store = State(initialValue: store)
    }

    var body: some View {
        Group {
            switch store.stage {
            case .login:
                LoginView()
            case .onboarding:
                LanguageOnboardingView()
            case .main:
                MainTabView()
            }
        }
        .environment(store)
        .tint(BrandTheme.jade)
        .animation(.easeInOut(duration: 0.3), value: store.stage)
    }
}

#Preview("Login") {
    ContentView()
}

#Preview("Onboarding") {
    ContentView(store: AppSessionStore.preview(.onboarding))
}

#Preview("Main App") {
    ContentView(store: AppSessionStore.preview(.main))
}
