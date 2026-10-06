import Foundation

enum ChatMessageType: String, Hashable {
    case text
    case voiceNote
    case meetingInvite
}

enum InviteStatus: String, Hashable {
    case pending
    case accepted
    case declined

    var title: String {
        switch self {
        case .pending: "Awaiting Reply"
        case .accepted: "Accepted"
        case .declined: "Declined"
        }
    }
}

struct MeetingInvite: Identifiable, Hashable {
    let id: UUID
    let title: String
    let venueName: String
    let mtrStation: String?
    let startDate: Date
    var status: InviteStatus

    init(
        id: UUID = UUID(),
        title: String,
        venueName: String,
        mtrStation: String? = nil,
        startDate: Date,
        status: InviteStatus = .pending
    ) {
        self.id = id
        self.title = title
        self.venueName = venueName
        self.mtrStation = mtrStation
        self.startDate = startDate
        self.status = status
    }

    var scheduledText: String {
        startDate.formatted(date: .abbreviated, time: .shortened)
    }

    var toMeetingType: MeetingType {
        venueName == MockData.voiceCallVenueName ? .voiceCall : .inPerson
    }
}

struct ChatMessage: Identifiable, Hashable {
    let id: UUID
    let conversationId: UUID
    let senderId: UUID
    let senderName: String
    let senderRole: UserRole
    var text: String?
    var jyutping: String?
    var translation: String?
    var audioUrl: String?
    var audioDuration: TimeInterval?
    var timestamp: Date
    var messageType: ChatMessageType
    var invite: MeetingInvite?

    init(
        id: UUID = UUID(),
        conversationId: UUID,
        senderId: UUID,
        senderName: String,
        senderRole: UserRole,
        text: String? = nil,
        jyutping: String? = nil,
        translation: String? = nil,
        audioUrl: String? = nil,
        audioDuration: TimeInterval? = nil,
        timestamp: Date,
        messageType: ChatMessageType,
        invite: MeetingInvite? = nil
    ) {
        self.id = id
        self.conversationId = conversationId
        self.senderId = senderId
        self.senderName = senderName
        self.senderRole = senderRole
        self.text = text
        self.jyutping = jyutping
        self.translation = translation
        self.audioUrl = audioUrl
        self.audioDuration = audioDuration
        self.timestamp = timestamp
        self.messageType = messageType
        self.invite = invite
    }

    var hasLanguageGuide: Bool {
        let hasJyutping = !(jyutping?.isEmpty ?? true)
        let hasTranslation = !(translation?.isEmpty ?? true)
        return hasJyutping || hasTranslation
    }

    var isFromElder: Bool {
        senderRole == .elderMentor
    }

    var durationText: String {
        guard let audioDuration else { return "0:00" }
        let totalSeconds = Int(audioDuration.rounded())
        return String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60)
    }

    var timeText: String {
        timestamp.formatted(date: .omitted, time: .shortened)
    }

    var dayLabel: String {
        timestamp.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
    }

    static func placeholder(
        conversationId: UUID,
        senderId: UUID,
        senderName: String,
        senderRole: UserRole,
        text: String? = nil,
        timestamp: Date
    ) -> ChatMessage {
        ChatMessage(
            conversationId: conversationId,
            senderId: senderId,
            senderName: senderName,
            senderRole: senderRole,
            text: text,
            timestamp: timestamp,
            messageType: .text
        )
    }
}

struct ChatConversation: Identifiable, Hashable {
    let id: UUID
    let partner: MeetingPartner
    var topic: CulturalTopic
    var partnerSenderId: UUID
    var isPartnerOnline: Bool
    var unreadCount: Int
    var lastUpdated: Date
    var messages: [ChatMessage]

    init(
        id: UUID = UUID(),
        partner: MeetingPartner,
        topic: CulturalTopic,
        partnerSenderId: UUID = UUID(),
        isPartnerOnline: Bool = true,
        unreadCount: Int = 0,
        lastUpdated: Date = Date(),
        messages: [ChatMessage] = []
    ) {
        self.id = id
        self.partner = partner
        self.topic = topic
        self.partnerSenderId = partnerSenderId
        self.isPartnerOnline = isPartnerOnline
        self.unreadCount = unreadCount
        self.lastUpdated = lastUpdated
        self.messages = messages
    }

    func message(id: UUID) -> ChatMessage? {
        messages.first { $0.id == id }
    }

    func lastMessageText() -> String {
        guard let last = messages.last else { return "Say hello" }
        switch last.messageType {
        case .text: return last.text ?? ""
        case .voiceNote: return "Voice note (\(last.durationText))"
        case .meetingInvite: return "Meeting invitation"
        }
    }
}

struct CulturalIcebreaker: Identifiable, Hashable {
    let id: UUID
    let prompt: String
    let cantonese: String
    let jyutping: String
    let translation: String
    let topic: CulturalTopic
    let systemImage: String

    init(
        id: UUID = UUID(),
        prompt: String,
        cantonese: String,
        jyutping: String,
        translation: String,
        topic: CulturalTopic,
        systemImage: String
    ) {
        self.id = id
        self.prompt = prompt
        self.cantonese = cantonese
        self.jyutping = jyutping
        self.translation = translation
        self.topic = topic
        self.systemImage = systemImage
    }

    var composerText: String {
        "\(cantonese)（\(jyutping)）"
    }
}

struct ChatComposer: Equatable {
    var text: String = ""
    var jyutping: String?
    var translation: String?

    var hasGuide: Bool {
        !(jyutping?.isEmpty ?? true)
    }

    var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    mutating func clear() {
        text = ""
        jyutping = nil
        translation = nil
    }
}
