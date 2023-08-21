//
//  LoginView.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 15/08/23.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn

enum FocusableField: Hashable {
    case email
    case password
}

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    @FocusState private var focus: FocusableField?
    
    private func signiInWithEmailPassword() {
        Task {
            if await authManager.signInWithEmailPassword() == true {
                dismiss()
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack {
                    Text(NSLocalizedString("Entra in", comment: "Titolo login"))
                        .bold()
                        .font(.largeTitle)
                        .padding(.top, 40)
                    Text(NSLocalizedString("WatchWise", comment: "WatchWise"))
                        .bold()
                        .font(.largeTitle)
                        .foregroundColor(.accentColor)
                        .padding(.top, 40)
                }
                
                ClearableTextField(hint: "Email", text: $authManager.email, startIcon: "envelope", endIcon: "xmark.circle.fill", error: $authManager.errorLogin)
                    .focused($focus, equals: .email)
                    .submitLabel(.next)
                    .onSubmit {
                        self.focus = .password
                    }
                
                ToggleableSecureField(hint: "Password", text: $authManager.password, startIcon: "key", error: $authManager.errorLogin)
                    .focused($focus, equals: .password)
                    .submitLabel(.go)
                    .onSubmit {
                        signiInWithEmailPassword()
                    }
                
                if authManager.errorLogin {
                    Text(NSLocalizedString("Email o password errati", comment: "Errore login"))
                        .foregroundColor(.red)
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Button(action: {}) {
                    Text(NSLocalizedString("Password dimenticata?", comment: "Password dimenticata"))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .font(.footnote)
                        .padding(.trailing, 8)
                        .padding(.vertical, -8)
                }
                
                Button(action: signiInWithEmailPassword) {
                    if authManager.authenticationState != .authenticating {
                        Text(NSLocalizedString("Log in", comment: "Bottone login"))
                            .font(.title3)
                            .bold()
                            .frame(width: UIScreen.main.bounds.width - 100, height: 40)
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(!authManager.isValid)
                .buttonStyle(.borderedProminent)
                
                VStack(spacing:8){
                    Text(NSLocalizedString("Non hai ancora un account?", comment: "No account"))
                        .font(.subheadline)
                    Button(action: { authManager.switchFlow() }) {
                        HStack {
                            Image(systemName: "envelope")
                                .frame(width: 24, height: 24)
                            Text(NSLocalizedString("Registrati con email", comment: "Bottone registrazione"))
                        }
                        .frame(width: 200)
                    }
                }
                
                ZStack {
                    Divider()
                        .padding(.horizontal)
                    
                    Text(NSLocalizedString("oppure", comment: "Testo tra bottoni"))
                        .padding(.horizontal, 10)
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .background(Color(UIColor.systemBackground))
                }
                
                Button(action: {}) {
                    HStack {
                        Image("ic_google")
                            .resizable()
                            .frame(width: 24, height: 24)
                        Text(NSLocalizedString("Entra con Google", comment: "Bottone Google"))
                            .font(.title3)
                            .bold()
                    }
                    .frame(width: 200, height: 40)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
        }
    }
}
