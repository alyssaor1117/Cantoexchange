import SwiftUI

struct MessageBubbleView: View {
    let message: ChatMessage
    let isMine: Bool
    var showsSenderName: Bool = false
    var elderStyling: Bool = false
    var isGuideRevealed: Bool = false
    var isPlaying: Bool = false
    var playbackProgress: Double = 0
    var slowPlaybackEnabled: Bool = false
    var onTapGuide: () -> Void = {}
    var onTogglePlayback: () -> Void = {}
    var onToggleSlowPlayback: () -> Void = {}
    var onRespondToInvite: ((InviteStatus) -> Void)? = nil

    private var bubbleFont: Font {
        elderStyling ? .title3.weight(.semibold) : .body
    }

    private var bubbleBackground: some ShapeStyle {
        isMine
            ? AnyShapeStyle(BrandTheme.gradient)
            : AnyShapeStyle(elderStyling ? Color.white : Color(.secondarySystemBackground))
    }

    private var bubbleShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: 18,
            bottomLeadingRadius: isMine ? 18 : 5,
            bottomTrailingRadius: isMine ? 5 : 18,
            topTrailingRadius: 18,
            style: .continuous
        )
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isMine {
                Spacer(minLength: elderStyling ? 110 : 54)
            } else {
                senderBubble
            }

            VStack(alignment: isMine ? .trailing : .leading, spacing: 3) {
                if showsSenderName {
                    Text(message.senderName)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                bubble
                Text(message.timeText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            if !isMine {
                Spacer(minLength: elderStyling ? 110 : 54)
            }
        }
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var senderBubble: some View {
        if showsSenderName {
            AvatarBubble(
                name: message.senderName,
                size: elderStyling ? 36 : 28,
                tint: message.isFromElder ? BrandTheme.clay : BrandTheme.jade
            )
        } else {
            Color.clear.frame(width: elderStyling ? 36 : 28, height: 1)
        }
    }

    private var bubble: some View {
        bubbleContent
            .padding(.vertical, elderStyling ? 14 : 10)
            .padding(.horizontal, elderStyling ? 16 : 14)
            .background {
                bubbleShape
                    .fill(bubbleBackground)
                    .overlay(
                        bubbleShape.stroke(
                            elderStyling && !isMine ? Color.primary : Color.clear,
                            lineWidth: elderStyling ? 2 : 0
                        )
                    )
            }
            .contentShape(bubbleShape)
            .onTapGesture {
                if message.hasLanguageGuide {
                    onTapGuide()
                }
            }
    }

    @ViewBuilder
    private var bubbleContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            switch message.messageType {
            case .text:
                textContent
            case .voiceNote:
                voiceNoteContent
            case .meetingInvite:
                inviteContent
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var textContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let text = message.text {
                Text(text)
                    .font(bubbleFont)
                    .foregroundStyle(isMine ? .white : .primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if message.hasLanguageGuide {
                if isGuideRevealed {
                    revealedGuide
                } else {
                    guideHint
                }
            }
        }
    }

    private var guideHint: some View {
        HStack(spacing: 6) {
            Image(systemName: "character.book.closed.fill")
                .font(.caption)
            Text("Tap for Jyutping & English")
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(isMine ? Color.white.opacity(0.9) : BrandTheme.jade)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            (isMine ? Color.white.opacity(0.18) : BrandTheme.jade.opacity(0.12)),
            in: Capsule()
        )
        .accessibilityHidden(true)
    }

    private var revealedGuide: some View {
        VStack(alignment: .leading, spacing: 6) {
            Divider().opacity(0.35)
            if let jyutping = message.jyutping {
                Text(jyutping)
                    .font(.callout.weight(.semibold))
                    .italic()
                    .foregroundStyle(isMine ? Color.white.opacity(0.95) : BrandTheme.jadeDeep)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let translation = message.translation {
                Text(translation)
                    .font(.footnote)
                    .foregroundStyle(isMine ? Color.white.opacity(0.85) : .secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Pronunciation and translation")
    }

    private var voiceNoteContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Button(action: onTogglePlayback) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.title3)
                        .frame(width: elderStyling ? 52 : 42, height: elderStyling ? 52 : 42)
                        .background(
                            isMine ? Color.white.opacity(0.22) : BrandTheme.jade,
                            in: Circle()
                        )
                        .foregroundStyle(isMine ? .white : .white)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isPlaying ? "Pause voice note" : "Play voice note")

                VoiceWaveformView(
                    seed: message.id,
                    progress: isPlaying ? playbackProgress : 0,
                    tint: isMine ? Color.white : BrandTheme.jade,
                    isAnimating: isPlaying
                )
                .frame(height: elderStyling ? 40 : 30)

                Text(message.durationText)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(isMine ? Color.white.opacity(0.9) : .secondary)
            }

            if message.isFromElder {
                Button(action: onToggleSlowPlayback) {
                    Label(
                        slowPlaybackEnabled ? "0.8x Slow Audio · On" : "0.8x Slow Audio",
                        systemImage: slowPlaybackEnabled ? "tortoise.fill" : "hare.fill"
                    )
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        slowPlaybackEnabled
                            ? (isMine ? Color.white : BrandTheme.jade)
                            : (isMine ? Color.white.opacity(0.2) : BrandTheme.jade.opacity(0.14)),
                        in: Capsule()
                    )
                    .foregroundStyle(slowPlaybackEnabled && !isMine ? .white : (isMine ? .white : BrandTheme.jadeDeep))
                }
                .buttonStyle(.plain)
                .accessibilityHint("Plays the voice note slower so learners can follow the Cantonese")
            }
        }
    }

    @ViewBuilder
    private var inviteContent: some View {
        if let invite = message.invite {
            VStack(alignment: .leading, spacing: 10) {
                Label("Meeting Invitation", systemImage: "calendar.badge.plus")
                    .font(.caption.weight(.bold))
                    .textCase(.uppercase)
                    .foregroundStyle(isMine ? Color.white.opacity(0.85) : BrandTheme.clay)

                Text(invite.title)
                    .font(elderStyling ? .headline : .subheadline.weight(.bold))
                    .foregroundStyle(isMine ? .white : .primary)

                Label(invite.scheduledText, systemImage: "clock.fill")
                    .font(.footnote)
                    .foregroundStyle(isMine ? Color.white.opacity(0.9) : .secondary)

                Label(invite.venueName, systemImage: "mappin.and.ellipse")
                    .font(.footnote)
                    .foregroundStyle(isMine ? Color.white.opacity(0.9) : .secondary)

                if let mtr = invite.mtrStation {
                    Label(mtr, systemImage: "tram.fill")
                        .font(.caption)
                        .foregroundStyle(isMine ? Color.white.opacity(0.85) : .secondary)
                }

                switch invite.status {
                case .pending:
                    HStack(spacing: 8) {
                        Button {
                            onRespondToInvite?(.accepted)
                        } label: {
                            Label("Accept", systemImage: "checkmark")
                                .font(.subheadline.weight(.bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(BrandTheme.jade)

                        Button {
                            onRespondToInvite?(.declined)
                        } label: {
                            Label("Decline", systemImage: "xmark")
                                .font(.subheadline.weight(.bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.bordered)
                        .tint(isMine ? .white : .secondary)
                    }
                    .padding(.top, 2)
                case .accepted, .declined:
                    TagPill(
                        text: invite.status.title,
                        color: invite.status == .accepted ? BrandTheme.jade : .secondary,
                        systemImage: invite.status == .accepted ? "checkmark.circle.fill" : "xmark.circle.fill"
                    )
                }
            }
        }
    }
}

struct VoiceWaveformView: View {
    let seed: UUID
    var progress: Double = 0
    var tint: Color = BrandTheme.jade
    var isAnimating: Bool = false

    private var bars: [CGFloat] {
        let hex = seed.uuidString.replacingOccurrences(of: "-", with: "")
        var values: [CGFloat] = []
        var index = hex.startIndex
        while index < hex.endIndex, values.count < 26 {
            let next = hex.index(index, offsetBy: 2, limitedBy: hex.endIndex) ?? hex.endIndex
            if let byte = UInt8(hex[index..<next], radix: 16) {
                values.append(0.25 + CGFloat(byte % 100) / 100 * 0.75)
            }
            index = next
        }
        return values.isEmpty ? [0.5] : values
    }

    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            ForEach(Array(bars.enumerated()), id: \.offset) { index, height in
                Capsule()
                    .fill(tint.opacity(playedUpTo(index) ? 1 : 0.35))
                    .frame(width: 3, height: height * 30)
            }
        }
        .animation(isAnimating ? .linear(duration: 0.2) : .default, value: progress)
        .accessibilityHidden(true)
    }

    private func playedUpTo(_ index: Int) -> Bool {
        guard progress > 0 else { return false }
        let total = Double(bars.count)
        return Double(index) / total <= progress
    }
}

private func bubblePreviewMessage(isMine: Bool) -> ChatMessage {
    ChatMessage(
        conversationId: MockChatData.conversationMaryID,
        senderId: isMine ? MockChatData.learnerSenderID : MockChatData.elderSenderID,
        senderName: isMine ? MockData.learnerName : "Auntie Mary",
        senderRole: isMine ? .learner : .elderMentor,
        text: isMine ? "去茶樓飲茶要點叫嘢？" : "記住三樣嘢：一壺茶，兩籠點心，埋單就係「唔該」。",
        jyutping: isMine
            ? "Heoi3 caa4 lau4 jam2 caa4 jiu3 mong1 jiu3 dim2 jiu2 je5?"
            : "Gei3 zyu6 saam1 jo2 je5: jat1 wau2 caa4, loeng5 lung2 dim2 sam1.",
        translation: isMine
            ? "How do you order at a tea house?"
            : "Remember three things: a pot of tea, two baskets of dim sum, then the bill.",
        audioDuration: nil,
        timestamp: Date(),
        messageType: .text
    )
}

#Preview("Bubbles — Learner") {
    ScrollView {
        VStack(spacing: 12) {
            MessageBubbleView(message: bubblePreviewMessage(isMine: false), isMine: false, showsSenderName: true)
            MessageBubbleView(message: bubblePreviewMessage(isMine: true), isMine: true)
            MessageBubbleView(
                message: MockChatData.conversationWithAuntieMary.messages[2],
                isMine: false,
                showsSenderName: true,
                isPlaying: true,
                playbackProgress: 0.4
            )
            MessageBubbleView(
                message: MockChatData.conversationWithAuntieMary.messages[5],
                isMine: false,
                showsSenderName: false
            )
        }
        .padding()
    }
    .background(BrandTheme.cream)
}

#Preview("Bubbles — Elder High Contrast") {
    ScrollView {
        VStack(spacing: 12) {
            MessageBubbleView(
                message: bubblePreviewMessage(isMine: false),
                isMine: false,
                showsSenderName: true,
                elderStyling: true
            )
            MessageBubbleView(
                message: MockChatData.conversationWithSofia.messages[2],
                isMine: true,
                elderStyling: true,
                isGuideRevealed: true
            )
            MessageBubbleView(
                message: MockChatData.conversationWithAuntieMary.messages[2],
                isMine: false,
                elderStyling: true,
                isPlaying: true,
                playbackProgress: 0.55,
                slowPlaybackEnabled: true
            )
        }
        .padding()
    }
    .background(Color.white)
}
