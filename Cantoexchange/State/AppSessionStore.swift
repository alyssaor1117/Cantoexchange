import Foundation
import Observation
import SwiftUI

@Observable
final class AppSessionStore {
    var stage: AppStage = .login
    var phoneNumber: String = ""
    var nativeLanguage: NativeLanguage = .mandarin
    var fluencyChoice: CantoneseFluencyChoice?
    var assignedRole: UserRole = .learner
    var activePerspective: UserRole = .learner
    var selectedDistrict: HKDistrict?
    var selectedTopic: CulturalTopic?
    var searchText: String = ""

    var mentors: [MentorProfile] = MockData.mentors
    var incomingRequests: [ConversationRequest] = MockData.requests
    var meetings: [ScheduledMeeting] = MockData.sessions
    var conversations: [ChatConversation] = MockChatData.conversations

    var bannerMessage: BannerMessagePayload?

    init(stage: AppStage = .login) {
        self.stage = stage
    }

    var displayName: String {
        switch activePerspective {
        case .elderMentor: "Auntie Mary"
        case .learner: MockData.learnerName
        }
    }

    var homeDistrict: HKDistrict {
        switch activePerspective {
        case .elderMentor: .wanChai
        case .learner: MockData.learnerDistrict
        }
    }

    var fluencyLevel: CantoneseFluency {
        switch activePerspective {
        case .elderMentor: .native
        case .learner: fluencyChoice == .fluentMentor ? .fluent : .beginner
        }
    }

    var mentorsAvailableToBrowse: [MentorProfile] {
        switch activePerspective {
        case .elderMentor: mentors
        case .learner: filteredMentors
        }
    }

    var filteredMentors: [MentorProfile] {
        mentors.filter { mentor in
            let matchesDistrict = selectedDistrict == nil || mentor.district == selectedDistrict
            let matchesTopic = selectedTopic == nil || mentor.topics.contains(selectedTopic!)
            let matchesSearch = searchText.trimmingCharacters(in: .whitespaces).isEmpty
                || mentor.displayName.localizedCaseInsensitiveContains(searchText)
                || mentor.bio.localizedCaseInsensitiveContains(searchText)
                || mentor.topics.contains { $0.title.localizedCaseInsensitiveContains(searchText) }
            return matchesDistrict && matchesTopic && matchesSearch
        }
    }

    var pendingRequests: [ConversationRequest] {
        incomingRequests.filter { $0.status == .pending }
    }

    var handledRequests: [ConversationRequest] {
        incomingRequests.filter { $0.status != .pending }
    }

    var upcomingMeetings: [ScheduledMeeting] {
        meetings
            .filter { $0.status == .scheduled && $0.startDate > Date() }
            .sorted { $0.startDate < $1.startDate }
    }

    var pastMeetings: [ScheduledMeeting] {
        meetings
            .filter { $0.status != .scheduled || $0.startDate <= Date() }
            .sorted { $0.startDate > $1.startDate }
    }

    var topicsByMentor: [CulturalTopic] {
        let all = mentors.flatMap(\.topics)
        var seen: Set<CulturalTopic> = []
        return all.filter { seen.insert($0).inserted }
    }

    func completeLogin() {
        stage = .onboarding
    }

    func completeOnboarding() {
        let role = fluencyChoice?.assignedRole ?? .learner
        assignedRole = role
        activePerspective = role
        fluencyChoice = fluencyChoice ?? .learningLearner
        stage = .main
        showBanner(
            .init(
                kind: .success,
                title: "You are all set, \(displayName)",
                message: "Role assigned: \(role.title)."
            )
        )
    }

    func setPerspective(_ role: UserRole) {
        guard role != activePerspective else { return }
        activePerspective = role
        showBanner(
            .init(
                kind: .info,
                title: "Previewing \(role.title) view",
                message: "Prototype switch only — your real role is \(assignedRole.title)."
            )
        )
    }

    func signOut() {
        stage = .login
        fluencyChoice = nil
        assignedRole = .learner
        activePerspective = .learner
        selectedDistrict = nil
        selectedTopic = nil
        searchText = ""
        bannerMessage = nil
    }

    func resetPrototype() {
        mentors = MockData.mentors
        incomingRequests = MockData.requests
        meetings = MockData.sessions
        conversations = MockChatData.conversations
        showBanner(.init(kind: .info, title: "Mock data restored", message: nil))
    }

    func respond(to request: ConversationRequest, with status: ConversationRequestStatus) {
        guard let index = incomingRequests.firstIndex(where: { $0.id == request.id }) else { return }
        incomingRequests[index].status = status
        let verb = status == .accepted ? "accepted" : "declined"
        showBanner(
            .init(
                kind: status == .accepted ? .success : .info,
                title: "Request \(verb)",
                message: "\(request.learnerName) has been notified."
            )
        )
    }

    func scheduleMeeting(_ draft: ScheduledMeetingDraft, with partner: MeetingPartner) -> ScheduledMeeting {
        let meeting = ScheduledMeeting(
            partner: partner,
            topic: draft.topic,
            type: draft.type,
            startDate: draft.startDate,
            venue: draft.type == .voiceCall ? nil : draft.venue,
            notes: draft.notes
        )
        meetings.append(meeting)
        showBanner(
            .init(
                kind: .success,
                title: "Meeting confirmed",
                message: "\(partner.name) · \(meeting.startDate.formatted(date: .abbreviated, time: .shortened))"
            )
        )
        return meeting
    }

    func cancel(_ meeting: ScheduledMeeting) {
        guard let index = meetings.firstIndex(where: { $0.id == meeting.id }) else { return }
        meetings[index].status = .cancelled
        showBanner(.init(kind: .info, title: "Meeting cancelled", message: meeting.venueLabel))
    }

    func markCompleted(_ meeting: ScheduledMeeting) {
        guard let index = meetings.firstIndex(where: { $0.id == meeting.id }) else { return }
        meetings[index].status = .completed
    }

    func showBanner(_ payload: BannerMessagePayload) {
        bannerMessage = payload
    }

    func dismissBanner() {
        bannerMessage = nil
    }

    // MARK: - Chat

    var totalUnreadMessages: Int {
        conversations.reduce(0) { $0 + $1.unreadCount }
    }

    var elderDisplayName: String {
        "Auntie Mary"
    }

    func conversation(for partner: MeetingPartner) -> ChatConversation? {
        conversations.first { $0.partner.name == partner.name }
    }

    func conversation(id: UUID) -> ChatConversation? {
        conversations.first { $0.id == id }
    }

    func conversationIndex(id: UUID) -> Int? {
        conversations.firstIndex { $0.id == id }
    }

    func openConversation(with partner: MeetingPartner) -> UUID? {
        if let existing = conversation(for: partner) {
            markRead(id: existing.id)
            return existing.id
        }
        let newConversation = ChatConversation(
            partner: partner,
            topic: partner.role == .elderMentor ? .traditionalTeaHouses : .dimSumEtiquette
        )
        conversations.insert(newConversation, at: 0)
        return newConversation.id
    }

    func markRead(id: UUID) {
        guard let index = conversationIndex(id: id) else { return }
        conversations[index].unreadCount = 0
    }

    func senderIdentity(for role: UserRole, in conversation: ChatConversation) -> (id: UUID, name: String, role: UserRole) {
        if role == conversation.partner.role {
            return (conversation.partnerSenderId, conversation.partner.name, conversation.partner.role)
        }
        switch role {
        case .elderMentor:
            return (MockChatData.elderSenderID, elderDisplayName, .elderMentor)
        case .learner:
            return (MockChatData.learnerSenderID, MockData.learnerName, .learner)
        }
    }

    func sendText(
        _ text: String,
        jyutping: String?,
        translation: String?,
        from role: UserRole,
        in conversationId: UUID
    ) {
        guard let index = conversationIndex(id: conversationId) else { return }
        let sender = senderIdentity(for: role, in: conversations[index])
        conversations[index].messages.append(
            ChatMessage(
                conversationId: conversationId,
                senderId: sender.id,
                senderName: sender.name,
                senderRole: sender.role,
                text: text,
                jyutping: jyutping,
                translation: translation,
                timestamp: Date(),
                messageType: .text
            )
        )
        conversations[index].lastUpdated = Date()
        scheduleAutoReply(in: conversationId)
    }

    func sendVoiceNote(duration: TimeInterval, from role: UserRole, in conversationId: UUID) {
        guard let index = conversationIndex(id: conversationId) else { return }
        let sender = senderIdentity(for: role, in: conversations[index])
        conversations[index].messages.append(
            ChatMessage(
                conversationId: conversationId,
                senderId: sender.id,
                senderName: sender.name,
                senderRole: sender.role,
                audioUrl: "mock://cantexchange/\(UUID().uuidString).m4a",
                audioDuration: max(1, duration),
                timestamp: Date(),
                messageType: .voiceNote
            )
        )
        conversations[index].lastUpdated = Date()
        scheduleAutoReply(in: conversationId)
    }

    func sendInvite(
        _ invite: MeetingInvite,
        from role: UserRole,
        in conversationId: UUID
    ) {
        guard let index = conversationIndex(id: conversationId) else { return }
        let sender = senderIdentity(for: role, in: conversations[index])
        conversations[index].messages.append(
            ChatMessage(
                conversationId: conversationId,
                senderId: sender.id,
                senderName: sender.name,
                senderRole: sender.role,
                text: invite.title,
                timestamp: Date(),
                messageType: .meetingInvite,
                invite: invite
            )
        )
        conversations[index].lastUpdated = Date()
    }

    func postInvite(for meeting: ScheduledMeeting, from role: UserRole) {
        guard let conversation = conversation(for: meeting.partner) else { return }
        sendInvite(
            MeetingInvite(
                title: meeting.topic.title,
                venueName: meeting.venueLabel,
                mtrStation: meeting.mtrLabel,
                startDate: meeting.startDate,
                status: .accepted
            ),
            from: role,
            in: conversation.id
        )
    }

    func respond(to invite: MeetingInvite, in conversationId: UUID, with status: InviteStatus) {
        guard let index = conversationIndex(id: conversationId) else { return }
        guard let messageIndex = conversations[index].messages.firstIndex(where: {
            $0.invite?.id == invite.id
        }) else { return }

        conversations[index].messages[messageIndex].invite?.status = status
        let partner = conversations[index].partner
        let meeting = meetingFromInvite(invite, partner: partner, status: status)
        if status == .accepted {
            meetings.append(meeting)
            showBanner(
                .init(
                    kind: .success,
                    title: "Meetup added to Sessions",
                    message: "\(partner.name) · \(invite.scheduledText)"
                )
            )
        } else {
            showBanner(.init(kind: .info, title: "Meetup declined", message: partner.name))
        }
    }

    private func meetingFromInvite(
        _ invite: MeetingInvite,
        partner: MeetingPartner,
        status: InviteStatus
    ) -> ScheduledMeeting {
        ScheduledMeeting(
            partner: partner,
            topic: .traditionalTeaHouses,
            type: invite.toMeetingType,
            startDate: invite.startDate,
            venue: MockData.venues.first { $0.name == invite.venueName },
            notes: "Created from a chat invitation.",
            status: status == .accepted ? .scheduled : .cancelled
        )
    }

    func sendSimulatedCall(to partner: MeetingPartner) {
        showBanner(
            .init(
                kind: .info,
                title: "Calling \(partner.name)…",
                message: "Prototype: voice call UI only, no audio connection."
            )
        )
    }

    private func scheduleAutoReply(in conversationId: UUID) {
        guard let index = conversationIndex(id: conversationId) else { return }
        let partnerRole = conversations[index].partner.role
        let replyIndex = conversations[index].messages.count % MockChatData.cannedReplies(for: partnerRole).count
        let reply = MockChatData.cannedReplies(for: partnerRole)[replyIndex]

        Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(1400))
            guard let self else { return }
            guard let currentIndex = self.conversationIndex(id: conversationId) else { return }
            let sender = self.senderIdentity(for: partnerRole, in: self.conversations[currentIndex])
            self.conversations[currentIndex].messages.append(
                ChatMessage(
                    conversationId: conversationId,
                    senderId: sender.id,
                    senderName: sender.name,
                    senderRole: sender.role,
                    text: reply.text,
                    jyutping: reply.jyutping,
                    translation: reply.translation,
                    audioUrl: reply.type == .voiceNote ? "mock://cantexchange/\(UUID().uuidString).m4a" : nil,
                    audioDuration: reply.audioDuration,
                    timestamp: Date(),
                    messageType: reply.type
                )
            )
            self.conversations[currentIndex].lastUpdated = Date()
            self.conversations[currentIndex].isPartnerOnline = true
        }
    }

    static func preview(_ stage: AppStage = .main) -> AppSessionStore {
        let store = AppSessionStore(stage: stage)
        switch stage {
        case .login:
            store.phoneNumber = ""
        case .onboarding:
            store.nativeLanguage = .english
            store.fluencyChoice = .learningLearner
        case .main:
            store.fluencyChoice = .learningLearner
            store.assignedRole = .learner
            store.activePerspective = .learner
            store.stage = .main
        }
        return store
    }
}

struct BannerMessagePayload: Identifiable, Equatable {
    enum Kind: Equatable {
        case safety, info, success
    }

    let id = UUID()
    let kind: Kind
    let title: String
    let message: String?

    static func == (lhs: BannerMessagePayload, rhs: BannerMessagePayload) -> Bool {
        lhs.id == rhs.id
    }
}

extension BannerMessage.Kind {
    init(_ kind: BannerMessagePayload.Kind) {
        switch kind {
        case .safety: self = .safety
        case .info: self = .info
        case .success: self = .success
        }
    }
}
