//
//  LoginView.swift
//  StrafenProject
//
//  Created by Steven on 15.04.23.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    enum Referrer {
        case login
        case invitationLink
        case createClub
    }
    
    private enum SignInWithButtonType {
        case apple
        case google
    }
    
    private enum SignInErrorCode {
        case unknown
        case emailAlreadyInUse
        case weakPassword
        case userNotFound
        case wrongPassword
    }
    
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.dismiss) var dismiss
    
    private let referrer: Referrer
    
    private let completionHandler: () -> Void
    
    @State private var email = ""
    
    @State private var password = ""
    
    @State private var loginButtonDisabled = true
    
    @State private var forgotPasswordButtonDisabled = true
    
    @State private var isForgotPasswordHandledAlertShown = false
    
    @State private var isSignInErrorAlertShown = false
    
    @State private var signInErrorCode: SignInErrorCode?
    
    init(referrer: Referrer, afterSignIn completionHandler: @escaping () -> Void) {
        self.referrer = referrer
        self.completionHandler = completionHandler
    }
    
    var body: some View {
        VStack {
            self.signInWithEmail
            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.secondary)
                Text("login|or", comment: "Or text between login with email and login with apple / google.")
                    .font(.callout)
                    .foregroundColor(.secondary)
                Rectangle()
                    .foregroundColor(.secondary)
                    .frame(height: 1)
            }.padding(.horizontal)
                .padding(.vertical, 30)
            self.signInWithAppleButton
            self.signInWithGoogleButton
        }.navigationTitle(self.navigationTitle)
            .navigationBarTitleDisplayMode(.large)
            .alert(self.signInErrorAlertTitle, isPresented: self.$isSignInErrorAlertShown, presenting: self.signInErrorCode) { errorCode in
                Button {
                    self.signInErrorCode = nil
                    if errorCode == .userNotFound {
                        self.dismiss()
                    }
                } label: {
                    switch errorCode {
                    case .userNotFound:
                        Text("login|sign-in-error-alert|cancel-login-button", comment: "Cancel login button on sign in error alert when user is not found.")
                    default:
                        Text("login|sign-in-error-alert|try-again-button", comment: "Try again button on sign in error alert when an error occured.")
                    }
                }
            } message: { errorCode in
                switch errorCode {
                case .unknown:
                    Text("login|sign-in-error-alert|unknown-error-message", comment: "Sign in error alert message when an unknown error occured.")
                case .emailAlreadyInUse:
                    Text("login|sign-in-error-alert|email-in-use-message", comment: "Sign in error alert message when the specified email to register is already in use.")
                case .weakPassword:
                    Text("login|sign-in-error-alert|weak-password-message", comment: "Sign in error alert message when the specified password to register is too weak.")
                case .userNotFound:
                    Text("login|sign-in-error-alert|user-not-found-message", comment: "Sign in error alert message when the user with specified email doesn't exists.")
                case .wrongPassword:
                    Text("login|sign-in-error-alert|wrong-password-message", comment: "Sign in error alert message when the specified password for login is wrong.")
                }
            }
    }
    
    @ViewBuilder private var signInWithEmail: some View {
        VStack {
            Section {
                TextField(String(localized: "login|email-textfield-placeholder", comment: "Placeholder of the email input textfield."), text: self.$email)
                    .font(.title3)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding(5)
                    .background(Color(uiColor: .systemGray6))
                    .cornerRadius(5)
                    .onChange(of: self.email) { _ in
                        self.validateEmailAndPassword()
                    }
                SecureField(String(localized: "login|password-textfield-placeholder", comment: "Placeholder of the password input textfield."), text: self.$password)
                    .font(.title3)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding(5)
                    .background(Color(uiColor: .systemGray6))
                    .cornerRadius(5)
                    .onChange(of: self.password) { _ in
                        self.validateEmailAndPassword()
                    }
            }.padding(.horizontal)
            Button {
                Task {
                    await self.handleSignIn(with: .emailAndPassword(email: self.email, password: self.password))
                }
            } label: {
                Text(self.loginButtonText)
                    .font(.title2)
                    .frame(maxWidth: .infinity)
            }.buttonStyle(.borderedProminent)
                .disabled(self.loginButtonDisabled)
                .padding([.horizontal, .top])
            if self.referrer == .login {
                Button {
                    Task {
                        await self.handleForgotPassword()
                    }
                } label: {
                    Text("login|forgot-password", comment: "Button if you have forgot your password.")
                }.buttonStyle(.borderless)
                    .disabled(self.forgotPasswordButtonDisabled)
                    .padding(.horizontal)
                    .alert(String(localized: "login|forgot-password-confirm-message", comment: "Message to confirm that an email for password recovery is send."), isPresented: self.$isForgotPasswordHandledAlertShown) {
                        Button {} label: {
                            Text("ok-buttton", comment: "Button with ok text.")
                        }

                    }
            }
        }
    }
    
    @ViewBuilder private var signInWithAppleButton: some View {
        Button {
            Task {
                await self.handleSignIn(with: .apple)
            }
        } label: {
            HStack {
                Image(self.colorScheme == .light ? "apple_logo_white" : "apple_logo_black")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .padding(7.5)
                Spacer()
                Text(self.signInWithButtonText(.apple))
                    .foregroundColor(self.signInWithButtonTextColor(.apple))
                    .font(.title2)
                    .padding(.trailing, 7.5)
                Spacer()
            }.background(self.signInWithButtonColor(.apple))
                .cornerRadius(5)
        }.padding(.horizontal)
    }
    
    @ViewBuilder private var signInWithGoogleButton: some View {
        Button {
            Task {
                await self.handleSignIn(with: .google)
            }
        } label: {
            HStack {
                Image("google_logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    .padding(7.5)
                    .background(Color(red: 1, green: 1, blue: 1))
                    .cornerRadius(5)
                    .padding(2.5)
                Spacer()
                Text(self.signInWithButtonText(.google))
                    .foregroundColor(self.signInWithButtonTextColor(.google))
                    .font(.title2)
                    .fontWeight(.medium)
                    .padding(.trailing, 7.5)
                Spacer()
            }.background(self.signInWithButtonColor(.google))
                .cornerRadius(5)
                .overlay {
                    if self.colorScheme == .light {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(self.signInWithButtonTextColor(.google), lineWidth: 1.5)
                    }
                }
        }.padding(.horizontal)
    }
    
    private var navigationTitle: String {
        switch self.referrer {
        case .login:
            return String(localized: "login|login-title", comment: "Title of the login page.")
        case .invitationLink, .createClub:
            return String(localized: "login|sign-in-title", comment: "Title of the sign in page.")
        }
    }
    
    private var loginButtonText: String {
        switch self.referrer {
        case .login:
            return String(localized: "login|login-button", comment: "Login with email button.")
        case .invitationLink, .createClub:
            return String(localized: "login|sign-in-button", comment: "Sign in with email button.")
        }
    }
    
    private var signInErrorAlertTitle: String {
        switch self.referrer {
        case .login:
            return String(localized: "login|login-failed-alert", comment: "Login failed alert title.")
        case .invitationLink, .createClub:
            return String(localized: "login|sign-in-failed-alert", comment: "Sign in failed alert title")
        }
    }
    
    private func validateEmailAndPassword() {
        self.forgotPasswordButtonDisabled = false
        let emailRegex = #/^(?:[a-z0-9!#$%&'*+\/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+\/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])$/#
        let match = try! emailRegex.wholeMatch(in: self.email)
        if (match == nil) {
            self.loginButtonDisabled = true
            self.forgotPasswordButtonDisabled = true
        } else if self.password.count < 8 {
            self.loginButtonDisabled = true
        } else {
            self.loginButtonDisabled = false
        }
    }
    
    private func signInWithButtonText(_ type: SignInWithButtonType) -> String {
        switch (type, self.referrer) {
        case (.apple, .login):
            return String(localized: "login|login-with-apple-button", comment: "Login with apple button.")
        case (.apple, .invitationLink), (.apple, .createClub):
            return String(localized: "login|sign-in-with-apple-button", comment: "Sign in with apple button.")
        case (.google, .login):
            return String(localized: "login|login-with-google-button", comment: "Login with google button.")
        case (.google, .invitationLink), (.google, .createClub):
            return String(localized: "login|sign-in-with-google-button", comment: "Sign in with google button.")
        }
    }
    
    private func signInWithButtonColor(_ type: SignInWithButtonType) -> Color {
        switch (type, self.colorScheme) {
        case (.apple, .light):
            return Color(red: 0, green: 0, blue: 0)
        case (.apple, .dark):
            return Color(red: 1, green: 1, blue: 1)
        case (.google, .light):
            return Color(red: 1, green: 1, blue: 1)
        case (.google, .dark):
            return Color(red: 85 / 255, green: 130 / 255, blue: 244 / 255)
        @unknown default:
            return Color.white
        }
    }
    
    private func signInWithButtonTextColor(_ type: SignInWithButtonType) -> Color {
        switch (type, self.colorScheme) {
        case (.apple, .light):
            return Color(red: 1, green: 1, blue: 1)
        case (.apple, .dark):
            return Color(red: 0, green: 0, blue: 0)
        case (.google, .light):
            return Color(red: 137 / 255, green: 137 / 255, blue: 137 / 255)
        case (.google, .dark):
            return Color(red: 1, green: 1, blue: 1)
        @unknown default:
            return Color.black
        }
    }
    
    private func handleForgotPassword() async {
        self.isForgotPasswordHandledAlertShown = true
        try? await FirebaseAuthenticator.shared.forgotPassword(email: self.email)
    }
    
    private func handleSignIn(with method: FirebaseAuthenticator.SignInMethod) async {
        do {
            try await FirebaseAuthenticator.shared.signIn(with: method, createUser: self.referrer == .invitationLink || self.referrer == .createClub)
            self.completionHandler()
        } catch {
            guard (error as NSError).domain == AuthErrorDomain,
                  let errorCode = AuthErrorCode.Code(rawValue: (error as NSError).code) else {
                self.signInErrorCode = .unknown
                return self.isSignInErrorAlertShown = true
            }
            switch errorCode {
            case .emailAlreadyInUse:
                self.signInErrorCode = .emailAlreadyInUse
            case .weakPassword:
                self.signInErrorCode = .weakPassword
            case .userNotFound:
                self.signInErrorCode = .userNotFound
            case .wrongPassword:
                self.signInErrorCode = .weakPassword
            default:
                self.signInErrorCode = .unknown
            }
            self.isSignInErrorAlertShown = true
        }
    }
}
