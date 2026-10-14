import SwiftUI

enum BrandTheme {
    static let jade = Color(red: 0.07, green: 0.51, blue: 0.44)
    static let jadeDeep = Color(red: 0.03, green: 0.30, blue: 0.27)
    static let lantern = Color(red: 0.85, green: 0.24, blue: 0.20)
    static let clay = Color(red: 0.87, green: 0.47, blue: 0.22)
    static let cream = Color(red: 1.00, green: 0.98, blue: 0.94)
    static let ink = Color(red: 0.10, green: 0.11, blue: 0.13)
    static let slate = Color(red: 0.36, green: 0.39, blue: 0.43)

    static let gradient: LinearGradient = LinearGradient(
        colors: [jade, jadeDeep],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let heroGradient: LinearGradient = LinearGradient(
        colors: [jade, Color(red: 0.11, green: 0.62, blue: 0.55), jadeDeep],
        startPoint: .top,
        endPoint: .bottom
    )

    static let appTitle = "CantoExchange"
    static let appTagline = "Learn Cantonese. Share a lifetime of Hong Kong stories."

    static func color(for topic: CulturalTopic) -> Color {
        switch topic {
        case .traditionalTeaHouses: clay
        case .moviesFromTheEighties: lantern
        case .dimSumEtiquette: jade
        case .mahjongNights: Color(red: 0.35, green: 0.27, blue: 0.60)
        case .neonSignsAndMarkets: Color(red: 0.10, green: 0.45, blue: 0.72)
        case .starFerryAndMTR: Color(red: 0.20, green: 0.52, blue: 0.68)
        case .cantoneseOpera: Color(red: 0.72, green: 0.20, blue: 0.42)
        case .festivalsAndTaiO: Color(red: 0.90, green: 0.58, blue: 0.12)
        case .publicHousingLife: Color(red: 0.42, green: 0.44, blue: 0.48)
        }
    }
}

struct HeroCardBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(BrandTheme.heroGradient)
            .overlay(alignment: .topTrailing) {
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 180)
                    .offset(x: 50, y: -60)
            }
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}

struct CardSurface<Content: View>: View {
    var padding: CGFloat = 18
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.primary.opacity(0.05), lineWidth: 1)
            )
            .shadow(color: BrandTheme.ink.opacity(0.08), radius: 14, y: 8)
    }
}

struct TagPill: View {
    let text: String
    var color: Color = BrandTheme.jade
    var systemImage: String?

    var body: some View {
        HStack(spacing: 4) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.caption2)
            }
            Text(text)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .foregroundStyle(color)
        .background(color.opacity(0.12), in: Capsule())
    }
}

struct SectionHeader: View {
    let title: String
    var subtitle: String?
    var systemImage: String?

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.headline)
                    .foregroundStyle(BrandTheme.jade)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.title3.weight(.bold))
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 0)
        }
    }
}

struct AvatarBubble: View {
    let name: String
    var size: CGFloat = 56
    var tint: Color = BrandTheme.jade

    private var initials: String {
        let letters = name
            .split(separator: " ")
            .compactMap { $0.first }
            .map(String.init)
        if letters.count >= 2 {
            return letters.prefix(2).joined().uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(tint.opacity(0.18))
            Circle()
                .strokeBorder(tint.opacity(0.45), lineWidth: 2)
            Text(initials)
                .font(.system(size: size * 0.36, weight: .bold, design: .rounded))
                .foregroundStyle(tint)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

struct BannerMessage: View {
    enum Kind {
        case safety, info, success

        var color: Color {
            switch self {
            case .safety: BrandTheme.lantern
            case .info: BrandTheme.jade
            case .success: Color(red: 0.15, green: 0.55, blue: 0.30)
            }
        }

        var symbol: String {
            switch self {
            case .safety: "shield.lefthalf.filled.badge.checkmark"
            case .info: "info.circle.fill"
            case .success: "checkmark.seal.fill"
            }
        }
    }

    let kind: Kind
    let title: String
    var message: String?

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: kind.symbol)
                .font(.title3)
                .foregroundStyle(kind.color)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                if let message {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(kind.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(kind.color.opacity(0.35), lineWidth: 1)
        )
    }
}

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    var message: String?

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 42))
                .foregroundStyle(BrandTheme.jade.opacity(0.7))
            Text(title)
                .font(.headline)
            if let message {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

#Preview("Design System") {
    VStack(spacing: 16) {
        BannerMessage(kind: .safety, title: "Safety Notice", message: "For first-time offline meetups, we recommend public, well-lit places near MTR stations.")
        TagPill(text: "Traditional Tea Houses", color: BrandTheme.clay)
        CardSurface {
            SectionHeader(title: "Section", subtitle: "Helper", systemImage: "sparkles")
        }
    }
    .padding()
    .background(BrandTheme.cream)
}
