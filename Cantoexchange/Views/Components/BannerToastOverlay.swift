import SwiftUI

struct BannerToastOverlay: View {
    @Environment(AppSessionStore.self) private var store

    var body: some View {
        VStack(spacing: 0) {
            if let payload = store.bannerMessage {
                Button {
                    store.dismissBanner()
                } label: {
                    BannerMessage(
                        kind: BannerMessage.Kind(payload.kind),
                        title: payload.title,
                        message: payload.message
                    )
                    .shadow(color: BrandTheme.ink.opacity(0.15), radius: 16, y: 10)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .transition(.move(edge: .top).combined(with: .opacity))
                .task(id: payload.id) {
                    try? await Task.sleep(for: .seconds(3.5))
                    guard !Task.isCancelled else { return }
                    withAnimation(.easeInOut(duration: 0.25)) {
                        store.dismissBanner()
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: store.bannerMessage)
        .allowsHitTesting(store.bannerMessage != nil)
    }
}

#Preview("Banner Toast") {
    struct PreviewHost: View {
        @State private var store = AppSessionStore.preview(.main)

        var body: some View {
            ZStack(alignment: .top) {
                BrandTheme.cream.ignoresSafeArea()
                Text("Underlying screen content")
                    .padding(.top, 140)
                BannerToastOverlay()
            }
            .environment(store)
            .onAppear {
                store.showBanner(
                    .init(
                        kind: .success,
                        title: "Meeting confirmed",
                        message: "Auntie Mary · Sat 10:30"
                    )
                )
            }
        }
    }

    return PreviewHost()
}
