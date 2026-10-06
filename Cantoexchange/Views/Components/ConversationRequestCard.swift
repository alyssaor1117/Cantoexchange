import SwiftUI

struct ConversationRequestCard: View {
    let request: ConversationRequest
    var onAccept: () -> Void
    var onDecline: () -> Void
    var onScheduleMeeting: () -> Void
    var onMessage: () -> Void = {}

    var body: some View {
        CardSurface {
            VStack(alignment: .leading, spacing: 14) {
                header
                messageBlock
                HStack(spacing: 8) {
                    TagPill(
                        text: request.learnerNativeLanguage.title,
                        color: BrandTheme.clay,
                        systemImage: "globe"
                    )
                    TagPill(
                        text: request.learnerFluency.title,
                        color: BrandTheme.jade,
                        systemImage: "waveform"
                    )
                    TagPill(
                        text: request.topic.title,
                        color: BrandTheme.color(for: request.topic),
                        systemImage: request.topic.systemImage
                    )
                }
                Text("Preferred time: \(request.preferredTimeText)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                actions
            }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            AvatarBubble(name: request.learnerName, size: 52, tint: BrandTheme.clay)
            VStack(alignment: .leading, spacing: 3) {
                Text(request.learnerName)
                    .font(.headline)
                Text("Wants to learn: \(request.topic.title)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(request.learnerDistrict.cantoneseName)
                    .font(.caption)
                    .foregroundStyle(BrandTheme.jadeDeep)
            }
            Spacer(minLength: 0)
            statusBadge
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch request.status {
        case .pending:
            TagPill(text: "New", color: BrandTheme.lantern, systemImage: "bell.badge.fill")
        case .accepted:
            TagPill(text: "Accepted", color: BrandTheme.jade, systemImage: "checkmark.circle.fill")
        case .declined:
            TagPill(text: "Declined", color: .secondary, systemImage: "xmark.circle.fill")
        }
    }

    private var messageBlock: some View {
        Text(request.message)
            .font(.body)
            .fixedSize(horizontal: false, vertical: true)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    @ViewBuilder
    private var actions: some View {
        switch request.status {
        case .pending:
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    Button(action: onAccept) {
                        Label("Accept", systemImage: "checkmark")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(BrandTheme.jade)

                    Button(action: onDecline) {
                        Label("Decline", systemImage: "xmark")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.bordered)
                    .tint(.secondary)
                }

                messageButton
            }
        case .accepted:
            VStack(spacing: 10) {
                Button(action: onScheduleMeeting) {
                    Label("Schedule Offline Meeting", systemImage: "calendar.badge.plus")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(BrandTheme.jade)

                messageButton
            }
        case .declined:
            messageButton
        }
    }

    private var messageButton: some View {
        Button(action: onMessage) {
            Label("Message \(request.learnerName)", systemImage: "bubble.left.and.bubble.right.fill")
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
        .buttonStyle(.bordered)
        .tint(BrandTheme.jadeDeep)
    }
}

#Preview("Pending Request") {
    ScrollView {
        VStack(spacing: 16) {
            ConversationRequestCard(
                request: MockData.requests[0],
                onAccept: {},
                onDecline: {},
                onScheduleMeeting: {}
            )
            ConversationRequestCard(
                request: MockData.requests[3],
                onAccept: {},
                onDecline: {},
                onScheduleMeeting: {}
            )
        }
        .padding()
    }
    .background(BrandTheme.cream)
}
