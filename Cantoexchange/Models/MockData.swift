import Foundation

enum MockData {
    private static func id(_ value: String) -> UUID {
        UUID(uuidString: value) ?? UUID()
    }

    private static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Hong_Kong") ?? .current
        return calendar
    }

    static func date(daysFromNow: Int, hour: Int, minute: Int = 0) -> Date {
        let base = calendar.date(byAdding: .day, value: daysFromNow, to: Date()) ?? Date()
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: base) ?? base
    }

    static let venues: [Venue] = [
        Venue(
            id: id("A1B2C3D4-0001-4000-8000-000000000001"),
            kind: .mtrCustomerService,
            name: "MTR Sham Shui Po Station Customer Service Center",
            mtrStation: "Sham Shui Po (Tsuen Wan Line)",
            district: .shamShuiPo,
            safetyNote: "Staffed counter, cameras and a busy concourse — ideal for a first meeting."
        ),
        Venue(
            id: id("A1B2C3D4-0001-4000-8000-000000000002"),
            kind: .mtrCustomerService,
            name: "MTR Sha Tin Station Customer Service Center",
            mtrStation: "Sha Tin (East Rail Line)",
            district: .shaTin,
            safetyNote: "Air-conditioned hall with seating right beside the station entrance."
        ),
        Venue(
            id: id("A1B2C3D4-0001-4000-8000-000000000003"),
            kind: .culturalCentre,
            name: "Hong Kong Cultural Centre, Piazza",
            mtrStation: "Tsim Sha Tsui (Tsuen Wan Line)",
            district: .wanChai,
            safetyNote: "Open public piazza with cafés, toilets and evening foot traffic."
        ),
        Venue(
            id: id("A1B2C3D4-0001-4000-8000-000000000004"),
            kind: .communityCentre,
            name: "Kowloon City Community Centre",
            mtrStation: "Hau Wong (Kwu Tung Line)",
            district: .kowloonCity,
            safetyNote: "Staffed community hall — tell the front desk your mentor's name on arrival."
        ),
        Venue(
            id: id("A1B2C3D4-0001-4000-8000-000000000005"),
            kind: .chaChaanTeng,
            name: "Ho Hung Kee Cha Chaan Teng",
            mtrStation: "Central (Island Line)",
            district: .centralAndWestern,
            safetyNote: "Busy daytime café — good light, loud enough for privacy, easy to leave."
        ),
        Venue(
            id: id("A1B2C3D4-0001-4000-8000-000000000006"),
            kind: .park,
            name: "Sha Tin Park Main Entrance",
            mtrStation: "Sha Tin (East Rail Line)",
            district: .shaTin,
            safetyNote: "Shaded benches and a visible main gate — bring water in summer."
        ),
        Venue(
            id: id("A1B2C3D4-0001-4000-8000-000000000007"),
            kind: .communityCentre,
            name: "Kwun Tong Community Hall",
            mtrStation: "Kwun Tong (Kwun Tong Line)",
            district: .kwunTong,
            safetyNote: "Quiet hall with a reception desk and accessible toilets."
        )
    ]

    static func venue(kind: VenueKind, district: HKDistrict) -> Venue {
        venues.first { $0.kind == kind && $0.district == district }
            ?? venues.first { $0.kind == kind }
            ?? venues[0]
    }

    static let mentors: [MentorProfile] = [
        MentorProfile(
            id: id("B1B2C3D4-0002-4000-8000-000000000001"),
            displayName: "Auntie Mary",
            ageRange: "60s",
            district: .wanChai,
            topics: [.traditionalTeaHouses, .dimSumEtiquette, .festivalsAndTaiO],
            fluency: .native,
            nativeLanguages: [.mandarin],
            bio: "I ran a tea house in Wan Chai for 32 years. Happy to teach you how to order like a regular, and why we always say 「唔該」 first.",
            yearsInHongKong: 62,
            completedSessions: 48,
            rating: 4.9,
            availabilityNote: "Free weekday mornings and Saturday all day"
        ),
        MentorProfile(
            id: id("B1B2C3D4-0002-4000-8000-000000000002"),
            displayName: "Uncle Wong",
            ageRange: "70s",
            district: .kowloonCity,
            topics: [.moviesFromTheEighties, .cantoneseOpera, .mahjongNights],
            fluency: .native,
            nativeLanguages: [.mandarin],
            bio: "Kowloon City born. Bring your 1980s film list — we will argue about the endings and sing the theme tunes.",
            yearsInHongKong: 74,
            completedSessions: 91,
            rating: 5.0,
            availabilityNote: "Tuesdays and Thursdays after 4pm"
        ),
        MentorProfile(
            id: id("B1B2C3D4-0002-4000-8000-000000000003"),
            displayName: "Uncle Lam",
            ageRange: "60s",
            district: .shamShuiPo,
            topics: [.neonSignsAndMarkets, .publicHousingLife, .dimSumEtiquette],
            fluency: .native,
            nativeLanguages: [.mandarin],
            bio: "Sham Shui Po since 1979. I can show you how to shop a wet market and read the handwritten signs most people cannot.",
            yearsInHongKong: 65,
            completedSessions: 37,
            rating: 4.8,
            availabilityNote: "Mornings before noon, Monday to Friday"
        ),
        MentorProfile(
            id: id("B1B2C3D4-0002-4000-8000-000000000004"),
            displayName: "Auntie Chan",
            ageRange: "50s",
            district: .shaTin,
            topics: [.mahjongNights, .festivalsAndTaiO, .publicHousingLife],
            fluency: .fluent,
            nativeLanguages: [.mandarin, .english],
            bio: "New Town mum, Mahjong teacher on weekends. We will practise the small talk that happens around a Mahjong table.",
            yearsInHongKong: 58,
            completedSessions: 24,
            rating: 4.7,
            availabilityNote: "Weekend afternoons"
        ),
        MentorProfile(
            id: id("B1B2C3D4-0002-4000-8000-000000000005"),
            displayName: "Uncle Cheung",
            ageRange: "50s",
            district: .centralAndWestern,
            topics: [.starFerryAndMTR, .traditionalTeaHouses, .neonSignsAndMarkets],
            fluency: .native,
            nativeLanguages: [.mandarin, .english],
            bio: "Ferry and tram nerd. Let us ride the Star Ferry and I will explain Octopus, the fare tables and who invented 八達通.",
            yearsInHongKong: 71,
            completedSessions: 63,
            rating: 4.9,
            availabilityNote: "Wednesday and Sunday mornings"
        ),
        MentorProfile(
            id: id("B1B2C3D4-0002-4000-8000-000000000006"),
            displayName: "Auntie Ho",
            ageRange: "70s",
            district: .kwunTong,
            topics: [.festivalsAndTaiO, .cantoneseOpera, .traditionalTeaHouses],
            fluency: .native,
            nativeLanguages: [.mandarin],
            bio: "I cook for festivals every year — Lion Dance, Tai O boat races, Mid-Autumn. Come with questions and an appetite.",
            yearsInHongKong: 69,
            completedSessions: 15,
            rating: 4.6,
            availabilityNote: "Sundays and public holiday Mondays"
        )
    ]

    static let learnerName = "Sofia"
    static let learnerDistrict: HKDistrict = .shamShuiPo
    static let learnerNativeLanguage: NativeLanguage = .english

    static let requests: [ConversationRequest] = [
        ConversationRequest(
            id: id("C1C2C3D4-0003-4000-8000-000000000001"),
            learnerName: "Sofia",
            learnerDistrict: .shamShuiPo,
            learnerNativeLanguage: .english,
            learnerFluency: .beginner,
            topic: .dimSumEtiquette,
            message: "Hello! I moved to Sham Shui Po last year and I always feel lost ordering dim sum. Could you help me practise saying the tea names out loud?",
            preferredTimeText: "Weekday mornings",
            status: .pending
        ),
        ConversationRequest(
            id: id("C1C2C3D4-0003-4000-8000-000000000002"),
            learnerName: "Rizal",
            learnerDistrict: .kwunTong,
            learnerNativeLanguage: .bahasaIndonesia,
            learnerFluency: .conversational,
            topic: .publicHousingLife,
            message: "Saya belajar Cantonese selama dua tahun. Saya ingin belajar tentang kehidupan di kota dan cara bertanya kepada petugas MTR. Terima kasih!",
            preferredTimeText: "Saturday afternoon",
            status: .pending
        ),
        ConversationRequest(
            id: id("C1C2C3D4-0003-4000-8000-000000000003"),
            learnerName: "Maria",
            learnerDistrict: .centralAndWestern,
            learnerNativeLanguage: .tagalog,
            learnerFluency: .beginner,
            topic: .starFerryAndMTR,
            message: "Kumusta! I am an exchange nurse in Central. Would you teach me the Cantonese I need for the Star Ferry and the clinic?",
            preferredTimeText: "Sunday morning",
            status: .pending
        ),
        ConversationRequest(
            id: id("C1C2C3D4-0003-4000-8000-000000000004"),
            learnerName: "Daniel",
            learnerDistrict: .shaTin,
            learnerNativeLanguage: .mandarin,
            learnerFluency: .conversational,
            topic: .mahjongNights,
            message: "我想學講廣州話同埋打麻雀嘅講法。Would a Tuesday evening work for you?",
            preferredTimeText: "Tuesday evening",
            status: .accepted
        )
    ]

    static var sessions: [ScheduledMeeting] {
        [
            ScheduledMeeting(
                id: id("D1D2C3D4-0004-4000-8000-000000000001"),
                partner: MeetingPartner(
                    name: mentors[0].displayName,
                    role: .elderMentor,
                    subtitle: "60s · Wan Chai",
                    district: .wanChai
                ),
                topic: .traditionalTeaHouses,
                type: .inPerson,
                startDate: date(daysFromNow: 3, hour: 10, minute: 30),
                venue: venues[2],
                notes: "Bring a notebook. We will do the full tea house ordering round."
            ),
            ScheduledMeeting(
                id: id("D1D2C3D4-0004-4000-8000-000000000002"),
                partner: MeetingPartner(
                    name: mentors[4].displayName,
                    role: .elderMentor,
                    subtitle: "50s · Central & Western",
                    district: .centralAndWestern
                ),
                topic: .starFerryAndMTR,
                type: .voiceCall,
                startDate: date(daysFromNow: 6, hour: 20),
                notes: "Voice call — practising transport vocabulary."
            ),
            ScheduledMeeting(
                id: id("D1D2C3D4-0004-4000-8000-000000000003"),
                partner: MeetingPartner(
                    name: "Daniel",
                    role: .learner,
                    subtitle: "Learner · Sha Tin",
                    district: .shaTin
                ),
                topic: .mahjongNights,
                type: .inPerson,
                startDate: date(daysFromNow: -9, hour: 18),
                venue: venues[1],
                notes: "Great first session — we covered the four winds and Cantonese greetings."
            ),
            ScheduledMeeting(
                id: id("D1D2C3D4-0004-4000-8000-000000000004"),
                partner: MeetingPartner(
                    name: "Rizal",
                    role: .learner,
                    subtitle: "Learner · Kwun Tong",
                    district: .kwunTong
                ),
                topic: .publicHousingLife,
                type: .inPerson,
                startDate: date(daysFromNow: -21, hour: 15),
                venue: venues[6],
                notes: "Cancelled by learner — typhoon signal 8.",
                status: .cancelled
            )
        ]
    }
}
