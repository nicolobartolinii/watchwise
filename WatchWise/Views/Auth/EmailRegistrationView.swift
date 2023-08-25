//
//  EmailRegistrationView.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 20/08/23.
//

import SwiftUI
import CoreHaptics
import FirebaseFirestore

private enum FocusableField: Hashable {
    case email
    case password
    case passwordConfirmation
}

struct EmailRegistrationView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var passwordConfirmation: String = ""
    @State private var emailError: Bool = false
    @State private var emailExistsError: Bool = false
    @State private var passwordNotValidError: Bool = false
    @State private var passwordConfirmationError: Bool = false
    
    private var subtitle1: Text = Text(NSLocalizedString("Inserisci il tuo ", comment: "Inserisci il tuo "))
    private var subtitle2: Text = Text(NSLocalizedString("indirizzo email ", comment: "indirizzo email "))
        .foregroundColor(.accentColor)
    private var subtitle3: Text = Text(NSLocalizedString("e una ", comment: "e una "))
    private var subtitle4: Text = Text(NSLocalizedString("password ", comment: "password "))
        .foregroundColor(.accentColor)
    
    @FocusState private var focus: FocusableField?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image("logo_title")
                    .resizable()
                    .scaledToFit()
                    .padding(.top)
                    .frame(width: UIScreen.main.bounds.width / 2.5, height: UIScreen.main.bounds.width / 2.5)
                Text(NSLocalizedString("Registrazione", comment: "Registrazione"))
                    .font(.largeTitle)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Group {
                    subtitle1 + subtitle2 + subtitle3 + subtitle4
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                
                ClearableTextField(hint: "Email", text: $authManager.email, startIcon: "envelope", endIcon: "xmark.circle.fill", error: $emailError)
                    .focused($focus, equals: .email)
                    .submitLabel(.next)
                    .onSubmit {
                        self.focus = .password
                    }
                
                if emailError {
                    Text(NSLocalizedString("Inserisci un indirizzo email valido", comment: "Inserisci un indirizzo email valido"))
                        .foregroundColor(.red)
                        .padding(.vertical, -12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.footnote)
                }
                
                if emailExistsError {
                    Text(NSLocalizedString("Indirizzo email non disponibile", comment: "Indirizzo email non disponibile"))
                        .foregroundColor(.red)
                        .padding(.vertical, -12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.footnote)
                }
                
                ToggleableSecureField(hint: "Password", text: $authManager.password, startIcon: "key", error: $passwordNotValidError)
                    .focused($focus, equals: .password)
                    .submitLabel(.next)
                    .onSubmit {
                        self.focus = .passwordConfirmation
                    }
                
                if passwordNotValidError {
                    Text(NSLocalizedString("La password deve contenere almeno 6 caratteri", comment: "La password deve contenere almeno 6 caratteri"))
                        .foregroundColor(.red)
                        .padding(.vertical, -12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.footnote)
                }
                
                ToggleableSecureField(hint: "Conferma password", text: $authManager.passwordConfirmation, startIcon: "lock", error: $passwordConfirmationError)
                    .focused($focus, equals: .passwordConfirmation)
                    .submitLabel(.go)
                    .onSubmit {
                        Task {
                            await continueRegistration()
                        }
                    }
                
                if passwordConfirmationError {
                    Text(NSLocalizedString("Le password non coincidono", comment: "Le password non coincidono"))
                        .foregroundColor(.red)
                        .padding(.vertical, -12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.footnote)
                }
                
                Button(action: {
                    Task {
                        await continueRegistration()
                    }
                }) {
                    Text(NSLocalizedString("Continua", comment: "Bottone continua"))
                        .font(.title3)
                        .bold()
                        .frame(width: UIScreen.main.bounds.width - 100, height: 40)
                }
                .buttonStyle(.borderedProminent)
                .navigationDestination(isPresented: $authManager.shouldNavigate, destination: {
                    CompleteRegistrationView()
                        .accentColor(.cyan)
                        .environmentObject(authManager)
                })
                
                HStack(spacing:8){
                    Text(NSLocalizedString("Hai già un account?", comment: "Hai già un account?"))
                        .font(.subheadline)
                    Button(action: {
                        authManager.reset()
                        authManager.switchFlow()
                    }) {
                        Text("Login")
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    
    func continueRegistration() async {
        emailError = false
        emailExistsError = false
        passwordNotValidError = false
        passwordConfirmationError = false
        checkEmail()
            do {
                let emailExists = try await checkEmailExists()
                if emailExists {
                    emailExistsError = true
                }
            } catch {
                print(error)
                emailExistsError = true
            }
        checkPassword()
        if emailError || emailExistsError || passwordNotValidError || passwordConfirmationError {
            triggerHapticFeedback()
        } else {
            authManager.shouldNavigate = true
        }
    }
    
    func checkEmail() {
        guard !authManager.email.isEmpty else {
            emailError = true
            return
        }
        if !authManager.email.isValidEmail() {
            emailError = true
            return
        }
    }
    
    func checkPassword() {
        if !authManager.password.isValidPassword() {
            passwordNotValidError = true
            return
        }
        if authManager.password != authManager.passwordConfirmation {
            passwordConfirmationError = true
            return
        }
    }
    
    func triggerHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    func checkEmailExists() async throws -> Bool {
        let db = Firestore.firestore()
        let usersRef = db.collection("users")
        let querySnapshot = try await usersRef.whereField("email", isEqualTo: authManager.email).getDocuments()
        return !querySnapshot.documents.isEmpty
    }
}

extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: self)
    }

    func isValidPassword() -> Bool {
        return self.count >= 6
    }
}

#Preview {
    EmailRegistrationView()
        .accentColor(.cyan)
}
