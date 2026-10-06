import SwiftUI

struct LoginView: View {
    @Environment(AppSessionStore.self) private var store
    @FocusState private var isPhoneFocused: Bool

    private var phoneBinding: Binding<String> {
        Binding(
            get: { store.phoneNumber },
            set: { store.phoneNumber = $0 }
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                hero
                loginCard(phone: phoneBinding)
                missionPoints
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
        .background(BrandTheme.cream.ignoresSafeArea())
        .scrollDismissesKeyboard(.interactively)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                HeroCardBackground()
                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: "character.book.closed.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                    Text(BrandTheme.appTitle)
                        .font(.largeTitle.weight(.heavy))
                        .foregroundStyle(.white)

                    Text(BrandTheme.appTagline)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.92))
                        .fixedSize(horizontal: false, vertical: true)

                    Text("「唔該Teach我講廣東話」")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.85))
                }
                .padding(22)
            }
            .frame(height: 260)
        }
    }

    private func loginCard(phone: Binding<String>) -> some View {
        CardSurface(padding: 20) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Sign in with your phone number")
                    .font(.headline)

                HStack(spacing: 10) {
                    Text("+852")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color(.tertiarySystemBackground), in: Capsule())

                    TextField("Mobile number", text: phone)
                        .keyboardType(.numberPad)
                        .textContentType(.telephoneNumber)
                        .focused($isPhoneFocused)
                        .font(.body)
                }
                .padding(12)
                .background(Color(.tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                Button {
                    isPhoneFocused = false
                    store.completeLogin()
                } label: {
                    Label("Send Verification Code", systemImage: "message.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(BrandTheme.jade)

                Text("Prototype: authentication is bypassed. Tapping the button goes straight to language onboarding.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Divider().opacity(0.4)

                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "lock.shield")
                        .font(.footnote)
                        .foregroundStyle(BrandTheme.jade)
                    Text("Your number is only used to match you with verified Hong Kong mentors.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var missionPoints: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Why CantoExchange", subtitle: "Two generations, one city", systemImage: "heart.fill")

            missionRow(
                icon: "person.wave.2.fill",
                title: "Cultural mentors share real memories",
                detail: "Tea houses, 1980s cinema, wet markets and neighbourhood life."
            )
            missionRow(
                icon: "graduationcap.fill",
                title: "Learners practise out loud",
                detail: "Everyday Cantonese instead of textbook phrases only."
            )
            missionRow(
                icon: "mappin.and.ellipse",
                title: "Meet safely, close to home",
                detail: "Public landmarks and MTR stations across Hong Kong districts."
            )
        }
    }

    private func missionRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(BrandTheme.jade)
                .frame(width: 38, height: 38)
                .background(BrandTheme.jade.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }
}

#Preview("Login") {
    LoginView()
        .environment(AppSessionStore.preview(.login))
}
