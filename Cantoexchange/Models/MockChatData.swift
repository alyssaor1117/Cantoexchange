import Foundation

extension MockData {
    static let voiceCallVenueName = "CantoExchange Voice Call"
}

enum MockChatData {
    static let learnerSenderID = UUID(uuidString: "E1E2C3D4-0005-4000-8000-00000000000A") ?? UUID()
    static let elderSenderID = UUID(uuidString: "E1E2C3D4-0005-4000-8000-00000000000B") ?? UUID()

    static let conversationMaryID = UUID(uuidString: "F1F2C3D4-0006-4000-8000-000000000001") ?? UUID()
    static let conversationWongID = UUID(uuidString: "F1F2C3D4-0006-4000-8000-000000000002") ?? UUID()
    static let conversationSofiaID = UUID(uuidString: "F1F2C3D4-0006-4000-8000-000000000003") ?? UUID()
    static let conversationRizalID = UUID(uuidString: "F1F2C3D4-0006-4000-8000-000000000004") ?? UUID()

    struct CannedReply {
        let text: String?
        let jyutping: String?
        let translation: String?
        let type: ChatMessageType
        let audioDuration: TimeInterval?
    }

    private static func msg(
        _ conversation: UUID,
        sender: UserRole,
        name: String,
        senderId: UUID,
        minutesAgo: Int,
        text: String? = nil,
        jyutping: String? = nil,
        translation: String? = nil,
        type: ChatMessageType = .text,
        audioDuration: TimeInterval? = nil,
        audioUrl: String? = nil,
        invite: MeetingInvite? = nil
    ) -> ChatMessage {
        ChatMessage(
            conversationId: conversation,
            senderId: senderId,
            senderName: name,
            senderRole: sender,
            text: text,
            jyutping: jyutping,
            translation: translation,
            audioUrl: audioUrl,
            audioDuration: audioDuration,
            timestamp: Date().addingTimeInterval(-Double(minutesAgo) * 60),
            messageType: type,
            invite: invite
        )
    }

    // MARK: - Conversations

    static var conversations: [ChatConversation] {
        [
            conversationWithAuntieMary,
            conversationWithUncleWong,
            conversationWithSofia,
            conversationWithRizal
        ]
    }

    static var conversationWithAuntieMary: ChatConversation {
        ChatConversation(
            id: conversationMaryID,
            partner: MeetingPartner(
                name: "Auntie Mary",
                role: .elderMentor,
                subtitle: "60s · Wan Chai",
                district: .wanChai
            ),
            topic: .traditionalTeaHouses,
            partnerSenderId: elderSenderID,
            isPartnerOnline: true,
            unreadCount: 1,
            lastUpdated: Date().addingTimeInterval(-60 * 6),
            messages: [
                msg(
                    conversationMaryID,
                    sender: .learner,
                    name: MockData.learnerName,
                    senderId: learnerSenderID,
                    minutesAgo: 180,
                    text: "Hello Auntie Mary! I moved to Wan Chai last month. I am learning Cantonese but I always freeze when I order in a tea house.",
                    translation: nil
                ),
                msg(
                    conversationMaryID,
                    sender: .elderMentor,
                    name: "Auntie Mary",
                    senderId: elderSenderID,
                    minutesAgo: 172,
                    text: "你好啊！唔使怕，我慢慢講，你跟住我講就得。",
                    jyutping: "Nei5 hou2 aa3! M4 sou2 paa3, Ngo5 maan2 maan1 gong2, Nei5 gan1 jau6 Ngo5 gong2 zau6 dak1.",
                    translation: "Hello! Don't be afraid — I'll speak slowly, just follow along with me."
                ),
                msg(
                    conversationMaryID,
                    sender: .elderMentor,
                    name: "Auntie Mary",
                    senderId: elderSenderID,
                    minutesAgo: 168,
                    type: .voiceNote,
                    audioDuration: 34,
                    audioUrl: "mock://cantexchange/mary/tea-order-01.m4a"
                ),
                msg(
                    conversationMaryID,
                    sender: .learner,
                    name: MockData.learnerName,
                    senderId: learnerSenderID,
                    minutesAgo: 44,
                    text: "去茶樓飲茶要點叫嘢？",
                    jyutping: "Heoi3 caa4 lau4 jam2 caa4 jiu3 mong1 jiu3 dim2 jiu2 je5?",
                    translation: "How do you order at a tea house?"
                ),
                msg(
                    conversationMaryID,
                    sender: .elderMentor,
                    name: "Auntie Mary",
                    senderId: elderSenderID,
                    minutesAgo: 12,
                    text: "記住三樣嘢：一壺茶，兩籠點心，埋單就係「唔該」同「多謝」。",
                    jyutping: "Gei3 zyu6 saam1 jo2 je5: Jat1 wau2 caa4, Loeng5 lung2 dim2 sam1, maai4 daan1 zau6 hai1 \"M4 goi1\" tung4 \"Doi1 ze6\".",
                    translation: "Remember three things: a pot of tea, two baskets of dim sum, and for the bill you say 唔該 (please) and 多謝 (thank you)."
                ),
                msg(
                    conversationMaryID,
                    sender: .elderMentor,
                    name: "Auntie Mary",
                    senderId: elderSenderID,
                    minutesAgo: 6,
                    text: "下個星期想唔想一齊去旺角食點心？",
                    jyutping: "Haa6 go3 sing1 kei4 soeng2 m4 soeng2 jat1 cai4 Mong4 Kok2 sik1 dim2 sam1?",
                    translation: "Do you want to go to Mong Kok for dim sum together next week?",
                    invite: MeetingInvite(
                        title: "Dim Sum at Ho Hung Kee",
                        venueName: "Ho Hung Kee Cha Chaan Teng",
                        mtrStation: "Mong Kok (East Rail Line)",
                        startDate: MockData.date(daysFromNow: 4, hour: 11, minute: 0)
                    )
                )
            ]
        )
    }

    static var conversationWithUncleWong: ChatConversation {
        ChatConversation(
            id: conversationWongID,
            partner: MeetingPartner(
                name: "Uncle Wong",
                role: .elderMentor,
                subtitle: "70s · Kowloon City",
                district: .kowloonCity
            ),
            topic: .moviesFromTheEighties,
            partnerSenderId: elderSenderID,
            isPartnerOnline: false,
            unreadCount: 0,
            lastUpdated: Date().addingTimeInterval(-60 * 60 * 26),
            messages: [
                msg(
                    conversationWongID,
                    sender: .learner,
                    name: MockData.learnerName,
                    senderId: learnerSenderID,
                    minutesAgo: 60 * 30,
                    text: "Uncle Wong, what is your favourite 1980s Hong Kong movie?"
                ),
                msg(
                    conversationWongID,
                    sender: .elderMentor,
                    name: "Uncle Wong",
                    senderId: elderSenderID,
                    minutesAgo: 60 * 28,
                    text: "《英雄本色》一定係第一位，仲有《省港旗兵》。",
                    jyutping: "\"Jing1 hung4 bun2 sik3\" jat1 ding4 hai1 dai1 jat1 wai2, zung6 jau5 \"Saang2 gong2 kei4 bing1\".",
                    translation: "A Better Tomorrow is definitely number one — and then again, The Haunted Cop."
                ),
                msg(
                    conversationWongID,
                    sender: .elderMentor,
                    name: "Uncle Wong",
                    senderId: elderSenderID,
                    minutesAgo: 60 * 26,
                    type: .voiceNote,
                    audioDuration: 52,
                    audioUrl: "mock://cantexchange/wong/movies-1980s.m4a"
                )
            ]
        )
    }

    static var conversationWithSofia: ChatConversation {
        ChatConversation(
            id: conversationSofiaID,
            partner: MeetingPartner(
                name: MockData.learnerName,
                role: .learner,
                subtitle: "Learner · Sham Shui Po",
                district: .shamShuiPo
            ),
            topic: .dimSumEtiquette,
            partnerSenderId: learnerSenderID,
            isPartnerOnline: true,
            unreadCount: 2,
            lastUpdated: Date().addingTimeInterval(-60 * 9),
            messages: [
                msg(
                    conversationSofiaID,
                    sender: .learner,
                    name: MockData.learnerName,
                    senderId: learnerSenderID,
                    minutesAgo: 150,
                    text: "Good morning! May I ask you something about dim sum etiquette?",
                    translation: nil
                ),
                msg(
                    conversationSofiaID,
                    sender: .elderMentor,
                    name: "Auntie Mary",
                    senderId: elderSenderID,
                    minutesAgo: 146,
                    text: "當然可以，問乜都得。",
                    jyutping: "Dang1 jin4 ho2 ji5, Man6 mat1 dou1 dak1.",
                    translation: "Of course — ask me anything."
                ),
                msg(
                    conversationSofiaID,
                    sender: .learner,
                    name: MockData.learnerName,
                    senderId: learnerSenderID,
                    minutesAgo: 40,
                    text: "點心蒸籠係咪要用筷子㗎？",
                    jyutping: "Dim2 sam2 zing1 lung4 hai6 mou2 jung6 coek3 zi2 gaa3?",
                    translation: "Do you use chopsticks for the dim sum steamers?"
                ),
                msg(
                    conversationSofiaID,
                    sender: .learner,
                    name: MockData.learnerName,
                    senderId: learnerSenderID,
                    minutesAgo: 9,
                    type: .voiceNote,
                    audioDuration: 8,
                    audioUrl: "mock://cantexchange/sofia/chopsticks-question.m4a"
                )
            ]
        )
    }

    static var conversationWithRizal: ChatConversation {
        ChatConversation(
            id: conversationRizalID,
            partner: MeetingPartner(
                name: "Rizal",
                role: .learner,
                subtitle: "Learner · Kwun Tong",
                district: .kwunTong
            ),
            topic: .publicHousingLife,
            partnerSenderId: learnerSenderID,
            isPartnerOnline: false,
            unreadCount: 0,
            lastUpdated: Date().addingTimeInterval(-60 * 60 * 8),
            messages: [
                msg(
                    conversationRizalID,
                    sender: .learner,
                    name: "Rizal",
                    senderId: learnerSenderID,
                    minutesAgo: 60 * 9,
                    text: "Maaf, saya belum yakin. Boleh saya tanya lagi?",
                    translation: "Sorry, I'm not sure yet — may I ask again?"
                ),
                msg(
                    conversationRizalID,
                    sender: .elderMentor,
                    name: "Auntie Mary",
                    senderId: elderSenderID,
                    minutesAgo: 60 * 8,
                    text: "你想學邊一種？",
                    jyutping: "Nei5 soeng2 hok6 bin1 jat1 cung2?",
                    translation: "Which kind would you like to learn?"
                )
            ]
        )
    }

    // MARK: - Canned replies

    static func cannedReplies(for partnerRole: UserRole) -> [CannedReply] {
        switch partnerRole {
        case .elderMentor:
            [
                CannedReply(
                    text: "好呀，我講慢啲你聽。",
                    jyutping: "Hou2 aa3, Ngo5 gong2 maan6 di1 nei5 teng1.",
                    translation: "Sure, I will speak more slowly for you.",
                    type: .text,
                    audioDuration: nil
                ),
                CannedReply(
                    text: nil,
                    jyutping: nil,
                    translation: nil,
                    type: .voiceNote,
                    audioDuration: 21
                ),
                CannedReply(
                    text: "我 send 段语音你听下，睇下明唔明白。",
                    jyutping: "Ngo5 saang3 dyun3 jyu5 jim1 nei5 teng1 haa2, tai2 haa2 ming4 m4 ming4 baak3.",
                    translation: "I will send you a voice note — listen and see if you understand.",
                    type: .text,
                    audioDuration: nil
                )
            ]
        case .learner:
            [
                CannedReply(
                    text: "多謝晒！我聽得明，個字我寫低。",
                    jyutping: "Doi1 ze6 saai3! Ngo5 teng1 dak1 ming4, go3 zi6 Ngo5 se2 daai3 dik1.",
                    translation: "Thank you so much! I understand — I will write that character down.",
                    type: .text,
                    audioDuration: nil
                ),
                CannedReply(
                    text: nil,
                    jyutping: nil,
                    translation: nil,
                    type: .voiceNote,
                    audioDuration: 6
                ),
                CannedReply(
                    text: "可唔可以再講慢一次？",
                    jyutping: "Ho2 m4 ho2 ji5 zoi3 gong2 maan6 jat1 ci3?",
                    translation: "Could you say that one more time, slowly?",
                    type: .text,
                    audioDuration: nil
                )
            ]
        }
    }

    // MARK: - Icebreakers

    static let icebreakers: [CulturalIcebreaker] = [
        CulturalIcebreaker(
            id: UUID(uuidString: "A2A2C3D4-0007-4000-8000-000000000001") ?? UUID(),
            prompt: "Ask about their favourite dim sum dish from childhood.",
            cantonese: "你細個最鍾意邊一款點心？",
            jyutping: "Nei5 sai3 go2 zeoi1 zung1 ji6 bin1 dou2 ti2 dim2 sum1?",
            translation: "Which dim sum dish did you like most as a child?",
            topic: .dimSumEtiquette,
            systemImage: "basket.fill"
        ),
        CulturalIcebreaker(
            id: UUID(uuidString: "A2A2C3D4-0007-4000-8000-000000000002") ?? UUID(),
            prompt: "Ask how Hong Kong transport changed over the decades.",
            cantonese: "而家搭車同以前有咩唔同？",
            jyutping: "Ji4 gaa1 daap3 ce1 tung4 jik5 cin4 jau5 me1 m4 tung4?",
            translation: "How is getting around different from before?",
            topic: .starFerryAndMTR,
            systemImage: "tram.fill"
        ),
        CulturalIcebreaker(
            id: UUID(uuidString: "A2A2C3D4-0007-4000-8000-000000000003") ?? UUID(),
            prompt: "Ask which 1980s Hong Kong film they watched again and again.",
            cantonese: "你記唔記得八十年代嘅港產片？",
            jyutping: "Nei5 gei3 m4 gei3 baat3 sap6 nin2 doi6 dik1 gong2 caan2 pin2?",
            translation: "Do you remember the 1980s Hong Kong movies?",
            topic: .moviesFromTheEighties,
            systemImage: "film.fill"
        ),
        CulturalIcebreaker(
            id: UUID(uuidString: "A2A2C3D4-0007-4000-8000-000000000004") ?? UUID(),
            prompt: "Ask them to teach you how to order like a regular at a tea house.",
            cantonese: "去茶樓飲茶要點叫嘢？",
            jyutping: "Heoi3 caa4 lau4 jam2 caa4 jiu3 mong1 jiu3 dim2 jiu2 je5?",
            translation: "How do you order at a cha chaan teng?",
            topic: .traditionalTeaHouses,
            systemImage: "cup.and.saucer.fill"
        ),
        CulturalIcebreaker(
            id: UUID(uuidString: "A2A2C3D4-0007-4000-8000-000000000005") ?? UUID(),
            prompt: "Ask which public housing estate they grew up in.",
            cantonese: "你哋以前住喺邊個邨？",
            jyutping: "Nei5 dei6 jik5 cin4 zyu6 hai2 bin1 go3 cyun1?",
            translation: "Which estate did you live in when you were younger?",
            topic: .publicHousingLife,
            systemImage: "building.3.fill"
        ),
        CulturalIcebreaker(
            id: UUID(uuidString: "A2A2C3D4-0007-4000-8000-000000000006") ?? UUID(),
            prompt: "Ask what they cooked for festivals as a child.",
            cantonese: "過年嗰陣你最鍾意食乜嘢？",
            jyutping: "Gwo3 nin4 go2 zan6 nei5 zeoi1 zung1 sik6 mat1 je5?",
            translation: "What did you most enjoy eating during New Year?",
            topic: .festivalsAndTaiO,
            systemImage: "flag.pattern.checkered"
        ),
        CulturalIcebreaker(
            id: UUID(uuidString: "A2A2C3D4-0007-4000-8000-000000000007") ?? UUID(),
            prompt: "Ask about the old neon signs in their neighbourhood.",
            cantonese: "你嗰區以前啲霓虹燈好靚，仲記唔記得？",
            jyutping: "Nei5 go2 keoi1 jik5 cin4 dik1 ngai4 hung4 dang1 hou2 leng3, zung6 gei3 m4 gei3 dak1?",
            translation: "The neon signs in your district were beautiful — do you still remember them?",
            topic: .neonSignsAndMarkets,
            systemImage: "light.recessional.3.fill"
        ),
        CulturalIcebreaker(
            id: UUID(uuidString: "A2A2C3D4-0007-4000-8000-000000000008") ?? UUID(),
            prompt: "Ask which phrase they shout at the mahjong table.",
            cantonese: "你打麻雀最鍾意講邊句？",
            jyutping: "Nei5 daa2 maa4 zok2 zeoi1 zung1 gong2 bin1 geoi3?",
            translation: "Which phrase do you say most when playing mahjong?",
            topic: .mahjongNights,
            systemImage: "square.grid.3x3.fill"
        ),
        CulturalIcebreaker(
            id: UUID(uuidString: "A2A2C3D4-0007-4000-8000-000000000009") ?? UUID(),
            prompt: "Ask them to teach you one Cantonese opera song.",
            cantonese: "你可唔可以教我唱一句粵曲？",
            jyutping: "Nei5 ho2 m4 ho2 ji5 giu3 Ngo5 coeng3 jat1 geoi3 jyut6 kek1?",
            translation: "Could you teach me to sing a line of Cantonese opera?",
            topic: .cantoneseOpera,
            systemImage: "theatermasks.fill"
        )
    ]
}
