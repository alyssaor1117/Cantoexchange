import Foundation

enum UserRole: String, CaseIterable, Identifiable, Hashable {
    case elderMentor
    case learner

    var id: String { rawValue }

    var title: String {
        switch self {
        case .elderMentor: "Cultural Mentor"
        case .learner: "Learner"
        }
    }

    var shortTitle: String {
        switch self {
        case .elderMentor: "Mentor"
        case .learner: "Learner"
        }
    }

    var systemImage: String {
        switch self {
        case .elderMentor: "person.wave.2.fill"
        case .learner: "graduationcap.fill"
        }
    }

    var blurb: String {
        switch self {
        case .elderMentor: "Share the Hong Kong you remember, one conversation at a time."
        case .learner: "Practise everyday Cantonese with a local mentor who has lived it."
        }
    }
}

enum NativeLanguage: String, CaseIterable, Identifiable, Hashable {
    case mandarin
    case english
    case bahasaIndonesia
    case tagalog
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .mandarin: "Mandarin"
        case .english: "English"
        case .bahasaIndonesia: "Bahasa Indonesia"
        case .tagalog: "Tagalog"
        case .other: "Other"
        }
    }

    var systemImage: String {
        switch self {
        case .mandarin: "character.bubble.fill"
        case .english: "textformat.abc"
        case .bahasaIndonesia: "globe.asia.australia.fill"
        case .tagalog: "globe.americas.fill"
        case .other: "character.bubble"
        }
    }

    var cantoneseName: String {
        switch self {
        case .mandarin: "普通話"
        case .english: "English"
        case .bahasaIndonesia: "Bahasa Indonesia"
        case .tagalog: "Tagalog"
        case .other: "其他"
        }
    }
}

enum CantoneseFluency: Int, CaseIterable, Identifiable, Hashable {
    case beginner
    case conversational
    case fluent
    case native

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .beginner: "Beginner"
        case .conversational: "Conversational"
        case .fluent: "Fluent"
        case .native: "Native Cantonese"
        }
    }

    var cantoneseName: String {
        switch self {
        case .beginner: "初級"
        case .conversational: "會話"
        case .fluent: "流利"
        case .native: "母語"
        }
    }

    var progress: Double {
        Double(rawValue + 1) / Double(CantoneseFluency.allCases.count)
    }
}

enum CantoneseFluencyChoice: String, CaseIterable, Identifiable, Hashable {
    case fluentMentor
    case learningLearner

    var id: String { rawValue }

    var title: String {
        switch self {
        case .fluentMentor: "Yes, I am fluent"
        case .learningLearner: "No, I am learning"
        }
    }

    var subtitle: String {
        switch self {
        case .fluentMentor: "I want to be a Cultural Mentor / Elder partner"
        case .learningLearner: "I want to practise Cantonese and meet local mentors"
        }
    }

    var systemImage: String {
        switch self {
        case .fluentMentor: "quote.bubble.fill"
        case .learningLearner: "character.book.closed.fill"
        }
    }

    var assignedRole: UserRole {
        switch self {
        case .fluentMentor: .elderMentor
        case .learningLearner: .learner
        }
    }
}

enum HKDistrict: String, CaseIterable, Identifiable, Hashable {
    case shamShuiPo
    case shaTin
    case centralAndWestern
    case wanChai
    case kowloonCity
    case kwunTong
    case tuenMun
    case islands

    var id: String { rawValue }

    var title: String {
        switch self {
        case .shamShuiPo: "Sham Shui Po"
        case .shaTin: "Sha Tin"
        case .centralAndWestern: "Central & Western"
        case .wanChai: "Wan Chai"
        case .kowloonCity: "Kowloon City"
        case .kwunTong: "Kwun Tong"
        case .tuenMun: "Tuen Mun"
        case .islands: "Islands District"
        }
    }

    var cantoneseName: String {
        switch self {
        case .shamShuiPo: "深水埗"
        case .shaTin: "沙田"
        case .centralAndWestern: "中西區"
        case .wanChai: "灣仔"
        case .kowloonCity: "九龍城"
        case .kwunTong: "觀塘"
        case .tuenMun: "屯門"
        case .islands: "離島區"
        }
    }

    var systemImage: String {
        switch self {
        case .shamShuiPo: "building.2.crop.circle"
        case .shaTin: "leaf.circle"
        case .centralAndWestern: "building.columns"
        case .wanChai: "ferry.circle"
        case .kowloonCity: "house.circle"
        case .kwunTong: "city.circle"
        case .tuenMun: "beach.umbrella.circle"
        case .islands: "mountain.2.circle"
        }
    }
}

enum CulturalTopic: String, CaseIterable, Identifiable, Hashable {
    case traditionalTeaHouses
    case moviesFromTheEighties
    case dimSumEtiquette
    case mahjongNights
    case neonSignsAndMarkets
    case starFerryAndMTR
    case cantoneseOpera
    case festivalsAndTaiO
    case publicHousingLife

    var id: String { rawValue }

    var title: String {
        switch self {
        case .traditionalTeaHouses: "Traditional Tea Houses"
        case .moviesFromTheEighties: "1980s HK Movies"
        case .dimSumEtiquette: "Dim Sum Etiquette"
        case .mahjongNights: "Mahjong Nights"
        case .neonSignsAndMarkets: "Neon Signs & Wet Markets"
        case .starFerryAndMTR: "Star Ferry & Octopus"
        case .cantoneseOpera: "Cantonese Opera"
        case .festivalsAndTaiO: "Festivals & Tai O"
        case .publicHousingLife: "Public Housing Life"
        }
    }

    var systemImage: String {
        switch self {
        case .traditionalTeaHouses: "cup.and.saucer.fill"
        case .moviesFromTheEighties: "film.fill"
        case .dimSumEtiquette: "basket.fill"
        case .mahjongNights: "square.grid.3x3.fill"
        case .neonSignsAndMarkets: "light.recessional.3.fill"
        case .starFerryAndMTR: "ferry.fill"
        case .cantoneseOpera: "theatermasks.fill"
        case .festivalsAndTaiO: "flag.pattern.checkered"
        case .publicHousingLife: "building.3.fill"
        }
    }
}

enum MeetingType: String, CaseIterable, Identifiable, Hashable {
    case inPerson
    case voiceCall

    var id: String { rawValue }

    var title: String {
        switch self {
        case .inPerson: "In-Person Meetup"
        case .voiceCall: "Online Voice Call"
        }
    }

    var subtitle: String {
        switch self {
        case .inPerson: "Local cha chaan teng, park or community centre in Hong Kong"
        case .voiceCall: "Voice call over CantoExchange — no travel needed"
        }
    }

    var systemImage: String {
        switch self {
        case .inPerson: "person.2.fill"
        case .voiceCall: "phone.fill"
        }
    }

    var requiresVenue: Bool {
        self == .inPerson
    }
}

enum VenueKind: String, CaseIterable, Identifiable, Hashable {
    case mtrCustomerService
    case culturalCentre
    case communityCentre
    case chaChaanTeng
    case park

    var id: String { rawValue }

    var title: String {
        switch self {
        case .mtrCustomerService: "MTR Station Customer Service Center"
        case .culturalCentre: "Hong Kong Cultural Centre"
        case .communityCentre: "Local Community Centre"
        case .chaChaanTeng: "Cha Chaan Teng (Local Café)"
        case .park: "Public Park"
        }
    }

    var systemImage: String {
        switch self {
        case .mtrCustomerService: "tram.fill"
        case .culturalCentre: "building.columns.fill"
        case .communityCentre: "building.2.fill"
        case .chaChaanTeng: "takeoutbag.and.cup.and.straw.fill"
        case .park: "leaf.fill"
        }
    }
}

struct Venue: Identifiable, Hashable {
    let id: UUID
    let kind: VenueKind
    let name: String
    let mtrStation: String
    let district: HKDistrict
    let safetyNote: String

    init(
        id: UUID = UUID(),
        kind: VenueKind,
        name: String,
        mtrStation: String,
        district: HKDistrict,
        safetyNote: String
    ) {
        self.id = id
        self.kind = kind
        self.name = name
        self.mtrStation = mtrStation
        self.district = district
        self.safetyNote = safetyNote
    }

    var googleMapsQuery: String {
        "\(name), \(mtrStation), Hong Kong"
    }

    var appleMapsURL: URL? {
        var components = URLComponents(string: "https://maps.apple.com/")
        components?.queryItems = [URLQueryItem(name: "daddr", value: googleMapsQuery)]
        return components?.url
    }
}

struct MentorProfile: Identifiable, Hashable {
    let id: UUID
    let displayName: String
    let ageRange: String
    let district: HKDistrict
    let topics: [CulturalTopic]
    let fluency: CantoneseFluency
    let nativeLanguages: [NativeLanguage]
    let bio: String
    let yearsInHongKong: Int
    let completedSessions: Int
    let rating: Double
    let isIdentityVerified: Bool
    let availabilityNote: String

    init(
        id: UUID = UUID(),
        displayName: String,
        ageRange: String,
        district: HKDistrict,
        topics: [CulturalTopic],
        fluency: CantoneseFluency,
        nativeLanguages: [NativeLanguage],
        bio: String,
        yearsInHongKong: Int,
        completedSessions: Int,
        rating: Double,
        isIdentityVerified: Bool = true,
        availabilityNote: String
    ) {
        self.id = id
        self.displayName = displayName
        self.ageRange = ageRange
        self.district = district
        self.topics = topics
        self.fluency = fluency
        self.nativeLanguages = nativeLanguages
        self.bio = bio
        self.yearsInHongKong = yearsInHongKong
        self.completedSessions = completedSessions
        self.rating = rating
        self.isIdentityVerified = isIdentityVerified
        self.availabilityNote = availabilityNote
    }

    var meetingPartner: MeetingPartner {
        MeetingPartner(
            name: displayName,
            role: .elderMentor,
            subtitle: "\(ageRange) · \(district.title)",
            district: district
        )
    }
}

enum ConversationRequestStatus: String, Identifiable, Hashable {
    case pending
    case accepted
    case declined

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pending: "New"
        case .accepted: "Accepted"
        case .declined: "Declined"
        }
    }
}

struct ConversationRequest: Identifiable, Hashable {
    let id: UUID
    let learnerName: String
    let learnerDistrict: HKDistrict
    let learnerNativeLanguage: NativeLanguage
    let learnerFluency: CantoneseFluency
    let topic: CulturalTopic
    let message: String
    let preferredTimeText: String
    var status: ConversationRequestStatus

    init(
        id: UUID = UUID(),
        learnerName: String,
        learnerDistrict: HKDistrict,
        learnerNativeLanguage: NativeLanguage,
        learnerFluency: CantoneseFluency,
        topic: CulturalTopic,
        message: String,
        preferredTimeText: String,
        status: ConversationRequestStatus = .pending
    ) {
        self.id = id
        self.learnerName = learnerName
        self.learnerDistrict = learnerDistrict
        self.learnerNativeLanguage = learnerNativeLanguage
        self.learnerFluency = learnerFluency
        self.topic = topic
        self.message = message
        self.preferredTimeText = preferredTimeText
        self.status = status
    }

    var meetingPartner: MeetingPartner {
        MeetingPartner(
            name: learnerName,
            role: .learner,
            subtitle: "Learner · \(learnerDistrict.title)",
            district: learnerDistrict
        )
    }
}

struct MeetingPartner: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let role: UserRole
    let subtitle: String
    let district: HKDistrict

    var systemImage: String { role.systemImage }
}

enum MeetingStatus: String, Identifiable, Hashable {
    case scheduled
    case completed
    case cancelled

    var id: String { rawValue }

    var title: String {
        switch self {
        case .scheduled: "Scheduled"
        case .completed: "Completed"
        case .cancelled: "Cancelled"
        }
    }
}

struct ScheduledMeeting: Identifiable, Hashable {
    let id: UUID
    var partner: MeetingPartner
    var topic: CulturalTopic
    var type: MeetingType
    var startDate: Date
    var venue: Venue?
    var notes: String
    var status: MeetingStatus

    init(
        id: UUID = UUID(),
        partner: MeetingPartner,
        topic: CulturalTopic,
        type: MeetingType,
        startDate: Date,
        venue: Venue? = nil,
        notes: String = "",
        status: MeetingStatus = .scheduled
    ) {
        self.id = id
        self.partner = partner
        self.topic = topic
        self.type = type
        self.startDate = startDate
        self.venue = venue
        self.notes = notes
        self.status = status
    }

    var venueLabel: String {
        switch type {
        case .inPerson: venue?.name ?? "Venue to be confirmed"
        case .voiceCall: "CantoExchange Voice Call"
        }
    }

    var mtrLabel: String? {
        venue?.mtrStation
    }

    var isUpcoming: Bool {
        status == .scheduled && startDate > Date()
    }
}

struct ScheduledMeetingDraft {
    var type: MeetingType = .inPerson
    var startDate: Date = Date().addingTimeInterval(60 * 60 * 24)
    var venue: Venue?
    var topic: CulturalTopic = .traditionalTeaHouses
    var notes: String = ""
}

enum AppStage: Hashable {
    case login
    case onboarding
    case main
}
