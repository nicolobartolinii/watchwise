//
//  EmailRegistrationView.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 20/08/23.
//

import SwiftUI
import CoreHaptics

struct EmailRegistrationView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var passwordConfirmation: String = ""
    @State private var emailError: Bool = false
    @State private var passwordNotValidError: Bool = false
    @State private var passwordConfirmationError: Bool = false
    @State private var shouldNavigate = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text(NSLocalizedString("Registrazione", comment: "Registrazione"))
                .font(.largeTitle)
                .bold()
            
            Text(NSLocalizedString("Inserisci il tuo ", comment: "Inserisci il tuo ")) +
            Text(NSLocalizedString("indirizzo email ", comment: "indirizzo email "))
                .foregroundColor(.accentColor) +
            Text(NSLocalizedString("e una ", comment: "e una ")) +
            Text(NSLocalizedString("password ", comment: "password "))
                .foregroundColor(.accentColor)
            
            
            ClearableTextField(hint: "Email", text: $email, startIcon: "envelope", endIcon: "xmark.circle.fill", error: $emailError)
            
            if emailError {
                Text(NSLocalizedString("Inserisci un indirizzo email valido", comment: "Inserisci un indirizzo email valido"))
                    .foregroundColor(.red)
                    .padding(.vertical, -12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.footnote)
            }
            
            ToggleableSecureField(hint: "Password", text: $password, startIcon: "key", error: $passwordNotValidError)
            
            if passwordNotValidError {
                Text(NSLocalizedString("La password deve contenere almeno 6 caratteri", comment: "La password deve contenere almeno 6 caratteri"))
                    .foregroundColor(.red)
                    .padding(.vertical, -12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.footnote)
            }
            
            ToggleableSecureField(hint: "Conferma password", text: $passwordConfirmation, startIcon: "lock", error: $passwordConfirmationError)
            
            if passwordConfirmationError {
                Text(NSLocalizedString("Le password non coincidono", comment: "Le password non coincidono"))
                    .foregroundColor(.red)
                    .padding(.vertical, -12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.footnote)
            }
            
            Button(action: continueRegistration) {
                Text(NSLocalizedString("Continua", comment: "Bottone continua"))
                    .font(.title3)
                    .bold()
                    .frame(width: 200, height: 40)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal)
    }
    
    func continueRegistration() {
        emailError = false
        passwordNotValidError = false
        passwordConfirmationError = false
        checkEmail()
        checkPassword()
        if emailError || passwordNotValidError || passwordConfirmationError {
            triggerHapticFeedback()
            return
        }
    }
    
    func checkEmail() {
        guard !email.isEmpty else {
            emailError = true
            return
        }
        if !email.isValidEmail() {
            emailError = true
            return
        }
    }
    
    func checkPassword() {
        if !password.isValidPassword() {
            passwordNotValidError = true
            return
        }
        if password != passwordConfirmation {
            passwordConfirmationError = true
            return
        }
    }
    
    func triggerHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
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
