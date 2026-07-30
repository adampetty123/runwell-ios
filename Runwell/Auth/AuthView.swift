import SwiftUI

struct AuthView: View {
    @EnvironmentObject var session: Session
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 22) {
                Spacer()
                Text("runwell")
                    .font(.system(size: 34, weight: .semibold, design: .rounded))
                    .foregroundColor(Theme.ink)
                Text("Your portfolio, in your pocket.")
                    .font(Theme.font).foregroundColor(Theme.muted)

                VStack(spacing: 12) {
                    field("Email", text: $email, secure: false)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    field("Password", text: $password, secure: true)
                }
                .padding(.top, 8)

                if let err = session.error {
                    Text(err).font(.footnote).foregroundColor(.red).multilineTextAlignment(.center)
                }

                Button {
                    Task { await session.login(email: email, password: password) }
                } label: {
                    HStack {
                        if session.loading { ProgressView().tint(Theme.bg) }
                        Text("Log in").fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(Theme.accent).foregroundColor(Theme.bg)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(session.loading || email.isEmpty || password.isEmpty)

                Spacer()
            }
            .padding(.horizontal, 28)
        }
    }

    @ViewBuilder private func field(_ ph: String, text: Binding<String>, secure: Bool) -> some View {
        Group {
            if secure { SecureField(ph, text: text) } else { TextField(ph, text: text) }
        }
        .padding(14)
        .background(Theme.soft)
        .foregroundColor(Theme.ink)
        .clipShape(RoundedRectangle(cornerRadius: 11))
        .overlay(RoundedRectangle(cornerRadius: 11).stroke(Theme.line, lineWidth: 1))
    }
}
