import SwiftUI

struct IcebreakerDrawer: View {
    let icebreakers: [CulturalIcebreaker]
    let isExpanded: Bool
    var elderStyling: Bool = false
    var onToggle: () -> Void
    var onSendPrompt: (CulturalIcebreaker) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            if isExpanded {
                Divider().opacity(0.3)
                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: 12) {
                        ForEach(icebreakers) { icebreaker in
                            card(for: icebreaker)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                }
                .scrollIndicators(.hidden)
                .frame(height: elderStyling ? 220 : 190)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(elderStyling ? Color.white : BrandTheme.cream)
        .overlay(alignment: .bottom) {
            Divider().opacity(0.3)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isExpanded)
    }

    private var header: some View {
        Button(action: onToggle) {
            HStack(spacing: 10) {
                Image(systemName: "lightbulb.fill")
                    .font(.subheadline)
                    .foregroundStyle(BrandTheme.clay)
                VStack(alignment: .leading, spacing: 1) {
                    Text("Need a Topic?")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.primary)
                    Text("Hong Kong cultural icebreakers with Cantonese + Jyutping")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.down")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(.secondary)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, elderStyling ? 14 : 11)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Need a Topic? Cultural icebreakers")
        .accessibilityHint(isExpanded ? "Double tap to collapse" : "Double tap to see conversation starters")
        .accessibilityAddTraits(isExpanded ? [.isButton, .isSelected] : .isButton)
    }

    private func card(for icebreaker: CulturalIcebreaker) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(icebreaker.topic.title, systemImage: icebreaker.systemImage)
                .font(.caption2.weight(.bold))
                .textCase(.uppercase)
                .foregroundStyle(BrandTheme.color(for: icebreaker.topic))
                .lineLimit(1)

            Text(icebreaker.prompt)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 3) {
                Text(icebreaker.cantonese)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(BrandTheme.jadeDeep)
                    .fixedSize(horizontal: false, vertical: true)
                Text(icebreaker.jyutping)
                    .font(.caption2)
                    .italic()
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button {
                onSendPrompt(icebreaker)
            } label: {
                Label("Send Prompt", systemImage: "arrow.up.doc.fill")
                    .font(.caption.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .tint(BrandTheme.jade)
        }
        .padding(12)
        .frame(width: 230, alignment: .leading)
        .background(
            Color(.secondarySystemBackground),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(BrandTheme.color(for: icebreaker.topic).opacity(0.35), lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
    }
}

#Preview("Icebreaker Drawer — Collapsed") {
    VStack {
        IcebreakerDrawer(
            icebreakers: MockChatData.icebreakers,
            isExpanded: false,
            onToggle: {},
            onSendPrompt: { _ in }
        )
        Spacer()
    }
    .background(Color.white)
}

#Preview("Icebreaker Drawer — Expanded") {
    VStack {
        IcebreakerDrawer(
            icebreakers: MockChatData.icebreakers,
            isExpanded: true,
            onToggle: {},
            onSendPrompt: { _ in }
        )
        Spacer()
    }
    .background(Color.white)
}

#Preview("Icebreaker Drawer — Elder") {
    VStack {
        IcebreakerDrawer(
            icebreakers: MockChatData.icebreakers,
            isExpanded: true,
            elderStyling: true,
            onToggle: {},
            onSendPrompt: { _ in }
        )
        Spacer()
    }
    .background(Color.white)
}
