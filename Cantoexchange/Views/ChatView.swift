import SwiftUI

struct ChatView: View {
    let partner: MeetingPartner
    let viewerRole: UserRole
    var onScheduled: ((ScheduledMeeting) -> Void)? = nil

    @Environment(AppSessionStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var conversationId: UUID?
    @State private var composer = ChatComposer()
    @State private var isDrawerExpanded = false
    @State private var guideMessage: ChatMessage?
    @State private var revealedMessageIDs: Set<UUID> = []
    @State private var playingMessageID: UUID?
    @State private var playbackProgress: Double = 0
    @State private var slowPlaybackEnabled = false
    @State private var isSchedulerPresented = false

    private var isElderViewer: Bool {
        viewerRole == .elderMentor
    }

    private var messages: [ChatMessage] {
        guard let conversationId else { return [] }
        return store.conversation(id: conversationId)?.messages ?? []
    }

    private var isPartnerOnline: Bool {
        guard let conversationId else { return false }
        return store.conversation(id: conversationId)?.isPartnerOnline ?? false
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            IcebreakerDrawer(
                icebreakers: MockChatData.icebreakers,
                isExpanded: isDrawerExpanded,
                elderStyling: isElderViewer,
                onToggle: { withAnimation { isDrawerExpanded.toggle() } },
                onSendPrompt: applyIcebreaker
            )
            messageList
            ChatInputBar(
                composer: $composer,
                elderStyling: isElderViewer,
                onSend: send,
                onRecordVoiceNote: sendVoiceNote
            )
        }
        .background(elderStylingBackground)
        .dynamicTypeSize(isElderViewer ? .accessibility2 : .large)
        .overlay {
            if let guideMessage {
                guideOverlay(for: guideMessage)
            }
        }
        .overlay(alignment: .top) {
            BannerToastOverlay()
        }
        .sheet(isPresented: $isSchedulerPresented) {
            OfflineMeetingSchedulerView(partner: partner, onScheduled: handleScheduled)
        }
        .task {
            conversationId = store.openConversation(with: partner)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            AvatarBubble(
                name: partner.name,
                size: isElderViewer ? 54 : 44,
                tint: partner.role == .elderMentor ? BrandTheme.clay : BrandTheme.jade
            )

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(partner.name)
                        .font(isElderViewer ? .title3.weight(.heavy) : .headline)
                    Circle()
                        .fill(isPartnerOnline ? BrandTheme.jade : Color.secondary.opacity(0.5))
                        .frame(width: 8, height: 8)
                }
                HStack(spacing: 6) {
                    Text(partner.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TagPill(
                        text: partner.role.title,
                        color: partner.role == .elderMentor ? BrandTheme.lantern : BrandTheme.jade,
                        systemImage: partner.role.systemImage
                    )
                }
            }

            Spacer(minLength: 0)

            Button {
                store.sendSimulatedCall(to: partner)
            } label: {
                Image(systemName: "phone.fill")
                    .font(.body)
                    .frame(width: isElderViewer ? 52 : 42, height: isElderViewer ? 52 : 42)
                    .background(BrandTheme.jade.opacity(0.15), in: Circle())
                    .foregroundStyle(BrandTheme.jadeDeep)
            }
            .buttonStyle(BouncyButtonStyle())
            .accessibilityLabel("Call \(partner.name)")

            Button {
                isSchedulerPresented = true
            } label: {
                Image(systemName: "calendar.badge.plus")
                    .font(.body)
                    .frame(width: isElderViewer ? 52 : 42, height: isElderViewer ? 52 : 42)
                    .background(BrandTheme.clay.opacity(0.18), in: Circle())
                    .foregroundStyle(BrandTheme.clay)
            }
            .buttonStyle(BouncyButtonStyle())
            .accessibilityLabel("Schedule meetup with \(partner.name)")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, isElderViewer ? 14 : 10)
        .background(.bar)
        .overlay(alignment: .bottom) {
            Divider().opacity(0.4)
        }
    }

    // MARK: - Messages

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 10) {
                    dayDivider
                    ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
                        MessageBubbleView(
                            message: message,
                            isMine: message.senderRole == viewerRole,
                            showsSenderName: showsSenderName(at: index),
                            elderStyling: isElderViewer,
                            isGuideRevealed: revealedMessageIDs.contains(message.id),
                            isPlaying: playingMessageID == message.id,
                            playbackProgress: playingMessageID == message.id ? playbackProgress : 0,
                            slowPlaybackEnabled: slowPlaybackEnabled,
                            onTapGuide: { toggleGuide(for: message) },
                            onTogglePlayback: { togglePlayback(for: message) },
                            onToggleSlowPlayback: { slowPlaybackEnabled.toggle() },
                            onRespondToInvite: { status in
                                guard let conversationId else { return }
                                if let invite = message.invite {
                                    store.respond(to: invite, in: conversationId, with: status)
                                }
                            }
                        )
                        .id(message.id)
                    }
                    Color.clear.frame(height: 1).id("chat-bottom")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: messages.count) {
                scrollToBottom(proxy, animated: true)
            }
            .onChange(of: conversationId) {
                scrollToBottom(proxy, animated: false)
            }
            .onAppear {
                scrollToBottom(proxy, animated: false)
            }
        }
        .task(id: playingMessageID) {
            await runPlaybackSimulation()
        }
    }

    private var dayDivider: some View {
        Text("Today · \(partner.district.title)")
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(Color(.tertiarySystemBackground).opacity(0.9))
            )
            .padding(.horizontal, 40)
    }

    private func showsSenderName(at index: Int) -> Bool {
        guard index > 0 else { return true }
        return messages[index - 1].senderId != messages[index].senderId
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy, animated: Bool) {
        guard animated else {
            proxy.scrollTo("chat-bottom", anchor: .bottom)
            return
        }
        withAnimation(.easeOut(duration: 0.25)) {
            proxy.scrollTo("chat-bottom", anchor: .bottom)
        }
    }

    private func runPlaybackSimulation() async {
        playbackProgress = 0
        guard playingMessageID != nil else { return }
        while playbackProgress < 1, !Task.isCancelled {
            try? await Task.sleep(for: .milliseconds(120))
            guard playingMessageID != nil else { break }
            let rate = slowPlaybackEnabled ? 0.8 : 1.0
            playbackProgress = min(1, playbackProgress + (0.06 * rate))
        }
        if playbackProgress >= 1 {
            playingMessageID = nil
            playbackProgress = 0
        }
    }

    // MARK: - Guide overlay

    private func guideOverlay(for message: ChatMessage) -> some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) { guideMessage = nil }
                }

            VStack {
                Spacer()
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "character.book.closed.fill")
                            .foregroundStyle(BrandTheme.jade)
                        Text("Cantonese Guide")
                            .font(.subheadline.weight(.bold))
                        Spacer(minLength: 0)
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { guideMessage = nil }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Close Cantonese guide")
                    }

                    Divider()

                    if let text = message.text {
                        Text(text)
                            .font(.title3.weight(.semibold))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    if let jyutping = message.jyutping {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("JYUTPING")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.secondary)
                            Text(jyutping)
                                .font(.callout.weight(.semibold))
                                .italic()
                                .foregroundStyle(BrandTheme.jadeDeep)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    if let translation = message.translation {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("ENGLISH")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.secondary)
                            Text(translation)
                                .font(.subheadline)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    Text("From \(message.senderName)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    isElderViewer ? Color.white : Color(.systemBackground),
                    in: RoundedRectangle(cornerRadius: 22, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(isElderViewer ? Color.primary : BrandTheme.jade.opacity(0.4), lineWidth: 2)
                )
                .padding(16)
            }
        }
        .transition(.opacity)
    }

    // MARK: - Actions

    private func toggleGuide(for message: ChatMessage) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if revealedMessageIDs.contains(message.id) {
                revealedMessageIDs.remove(message.id)
                if guideMessage?.id == message.id {
                    guideMessage = nil
                }
            } else {
                revealedMessageIDs.insert(message.id)
                guideMessage = message
            }
        }
    }

    private func togglePlayback(for message: ChatMessage) {
        if playingMessageID == message.id {
            playingMessageID = nil
            playbackProgress = 0
        } else {
            slowPlaybackEnabled = false
            playingMessageID = message.id
            playbackProgress = 0
        }
    }

    private func applyIcebreaker(_ icebreaker: CulturalIcebreaker) {
        composer.text = icebreaker.composerText
        composer.jyutping = icebreaker.jyutping
        composer.translation = icebreaker.translation
        withAnimation { isDrawerExpanded = false }
    }

    private func send() {
        guard composer.canSend, let conversationId else { return }
        let text = composer.text.trimmingCharacters(in: .whitespacesAndNewlines)
        store.sendText(
            text,
            jyutping: composer.hasGuide ? composer.jyutping : nil,
            translation: composer.hasGuide ? composer.translation : nil,
            from: viewerRole,
            in: conversationId
        )
        composer.clear()
    }

    private func sendVoiceNote(duration: TimeInterval) {
        guard let conversationId else { return }
        store.sendVoiceNote(duration: duration, from: viewerRole, in: conversationId)
    }

    private func handleScheduled(_ meeting: ScheduledMeeting) {
        store.postInvite(for: meeting, from: viewerRole)
        onScheduled?(meeting)
    }

    private var elderStylingBackground: some View {
        isElderViewer ? AnyView(Color.white) : AnyView(BrandTheme.cream)
    }
}

struct ChatRoomSheet: View {
    let partner: MeetingPartner
    let viewerRole: UserRole

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ChatView(partner: partner, viewerRole: viewerRole)
                .navigationTitle("Chat with \(partner.name)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { dismiss() }
                    }
                }
        }
    }
}

#Preview("Chat — Learner") {
    ChatRoomSheet(partner: MockData.mentors[0].meetingPartner, viewerRole: .learner)
        .environment(AppSessionStore.preview(.main))
}

#Preview("Chat — Elder (High Contrast)") {
    ChatRoomSheet(
        partner: MeetingPartner(
            name: MockData.learnerName,
            role: .learner,
            subtitle: "Learner · Sham Shui Po",
            district: .shamShuiPo
        ),
        viewerRole: .elderMentor
    )
    .environment(AppSessionStore.preview(.main))
}
