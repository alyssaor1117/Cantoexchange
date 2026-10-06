import SwiftUI
import UIKit

struct ChatInputBar: View {
    @Binding var composer: ChatComposer
    var elderStyling: Bool = false
    var onSend: () -> Void
    var onRecordVoiceNote: (TimeInterval) -> Void

    @State private var isRecording = false
    @State private var recordingStartedAt: Date?
    @State private var pulse = false

    private let quickReactions = ["🍵", "🥢", "🥮", "🇭🇰"]

    private var recordLabel: String {
        guard isRecording, let recordingStartedAt else { return "" }
        return String(format: "%.0fs", Date().timeIntervalSince(recordingStartedAt))
    }

    var body: some View {
        VStack(spacing: 8) {
            if composer.hasGuide {
                attachedGuide
            }

            if isRecording {
                recordingBar
            }

            HStack(alignment: .bottom, spacing: 10) {
                micButton
                textField
                sendButton
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.bar)
            .overlay(alignment: .top) {
                Divider().opacity(0.4)
            }
        }
        .background(.bar)
    }

    private var attachedGuide: some View {
        HStack(spacing: 10) {
            Image(systemName: "character.book.closed.fill")
                .font(.caption)
                .foregroundStyle(BrandTheme.jade)
            VStack(alignment: .leading, spacing: 2) {
                if let jyutping = composer.jyutping {
                    Text(jyutping)
                        .font(.caption.weight(.semibold))
                        .italic()
                        .foregroundStyle(BrandTheme.jadeDeep)
                        .lineLimit(1)
                }
                if let translation = composer.translation {
                    Text(translation)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
            Button {
                composer.jyutping = nil
                composer.translation = nil
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Remove pronunciation guide")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(BrandTheme.jade.opacity(0.1), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.horizontal, 12)
    }

    private var recordingBar: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(BrandTheme.lantern)
                .frame(width: 10, height: 10)
                .scaleEffect(pulse ? 1.25 : 0.85)
            Text("Recording voice note…")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            VoiceWaveformView(
                seed: UUID(uuidString: "00000000-0000-4000-8000-0000000000AA") ?? UUID(),
                progress: 0,
                tint: BrandTheme.lantern,
                isAnimating: isRecording
            )
            .frame(width: 90, height: 22)
            Text(recordLabel)
                .font(.caption.monospacedDigit().weight(.bold))
                .foregroundStyle(BrandTheme.lantern)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(BrandTheme.lantern.opacity(0.1), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.horizontal, 12)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }

    private var micButton: some View {
        Button {
        } label: {
            Image(systemName: isRecording ? "mic.fill" : "mic")
                .font(.title3)
                .frame(width: elderStyling ? 54 : 46, height: elderStyling ? 54 : 46)
                .background(
                    isRecording ? BrandTheme.lantern : BrandTheme.jade.opacity(0.15),
                    in: Circle()
                )
                .foregroundStyle(isRecording ? .white : BrandTheme.jadeDeep)
        }
        .buttonStyle(.plain)
        .scaleEffect(isRecording ? 1.06 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isRecording)
        .gesture(
            LongPressGesture(minimumDuration: 0.35)
                .onChanged { _ in
                    guard !isRecording else { return }
                    isRecording = true
                    recordingStartedAt = Date()
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
                .onEnded { _ in
                    finishRecording()
                }
        )
        .accessibilityLabel("Hold to record a voice note")
    }

    private var textField: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField(
                elderStyling ? "Type a message…" : "Type a message, or tap Need a Topic?",
                text: $composer.text,
                axis: .vertical
            )
            .lineLimit(1...(elderStyling ? 4 : 5))
            .font(elderStyling ? .title3 : .body)
            .submitLabel(.send)
            .onSubmit {
                if composer.canSend { onSend() }
            }

            HStack(spacing: 6) {
                ForEach(quickReactions, id: \.self) { emoji in
                    Button {
                        composer.text += emoji
                    } label: {
                        Text(emoji)
                            .font(.title3)
                            .frame(width: elderStyling ? 44 : 36, height: elderStyling ? 44 : 32)
                    }
                    .buttonStyle(.plain)
                    .background(BrandTheme.cream, in: Capsule())
                    .accessibilityLabel("Insert \(emoji)")
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            elderStyling ? Color.white : Color(.secondarySystemBackground),
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(elderStyling ? Color.primary.opacity(0.4) : Color.primary.opacity(0.08), lineWidth: 1)
        )
    }

    private var sendButton: some View {
        Button(action: onSend) {
            Image(systemName: "arrow.up")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: elderStyling ? 54 : 46, height: elderStyling ? 54 : 46)
                .background(
                    composer.canSend
                        ? AnyShapeStyle(BrandTheme.gradient)
                        : AnyShapeStyle(Color.secondary.opacity(0.3)),
                    in: Circle()
                )
        }
        .buttonStyle(BouncyButtonStyle())
        .disabled(!composer.canSend)
        .accessibilityLabel("Send message")
    }

    private func finishRecording() {
        let startedAt = recordingStartedAt
        isRecording = false
        recordingStartedAt = nil
        pulse = false
        guard let startedAt else { return }
        let duration = Date().timeIntervalSince(startedAt)
        guard duration >= 0.4 else { return }
        onRecordVoiceNote(duration)
    }
}

struct BouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.55), value: configuration.isPressed)
    }
}

private func inputBarPreviewComposer() -> ChatComposer {
    ChatComposer(
        text: "去茶樓飲茶要點叫嘢？",
        jyutping: "Heoi3 caa4 lau4 jam2 caa4 jiu3 mong1 jiu3 dim2 jiu2 je5?",
        translation: "How do you order at a tea house?"
    )
}

#Preview("Input Bar — Learner") {
    VStack {
        Spacer()
        ChatInputBar(composer: .constant(inputBarPreviewComposer()), onSend: {}, onRecordVoiceNote: { _ in })
    }
    .background(BrandTheme.cream)
}

#Preview("Input Bar — Empty") {
    VStack {
        Spacer()
        ChatInputBar(composer: .constant(ChatComposer()), onSend: {}, onRecordVoiceNote: { _ in })
    }
    .background(BrandTheme.cream)
}

#Preview("Input Bar — Elder High Contrast") {
    VStack {
        Spacer()
        ChatInputBar(
            composer: .constant(inputBarPreviewComposer()),
            elderStyling: true,
            onSend: {},
            onRecordVoiceNote: { _ in }
        )
    }
    .background(Color.white)
}
