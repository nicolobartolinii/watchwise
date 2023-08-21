//
//  CompleteRegistrationView.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 20/08/23.
//

import SwiftUI

struct CompleteRegistrationView: View {
    var email: String = ""
    var password: String = ""
    @State private var username: String = ""
    @State private var displayName: String = ""
    @State private var profileImage: Image? = nil
    @State private var usernameError: Bool = false
    @State private var displayNameError: Bool = false
    @State private var defaultPropicColor: Color = .accentColor
    var subtitle1: Text = Text(NSLocalizedString("Inserisci un ", comment: "Inserisci un "))
    var subtitle2: Text = Text(NSLocalizedString("nome utente", comment: "nome utente"))
        .foregroundColor(.accentColor)
    var subtitle3: Text = Text(NSLocalizedString(", un ", comment: ", un "))
    var subtitle4: Text = Text(NSLocalizedString("nome visualizzato ", comment: "nome visualizzato "))
        .foregroundColor(.accentColor)
    var subtitle5: Text = Text(NSLocalizedString("e, se vuoi, scegli un'", comment: "e, se vuoi, scegli un'"))
    var subtitle6: Text = Text(NSLocalizedString("immagine di profilo", comment: "immagine di profilo"))
        .foregroundColor(.accentColor)
    var subtitle7: Text = Text(NSLocalizedString(" (cambia il colore dell'immagine di default cliccando sul pulsante al suo fianco, altrimenti clicca sull'immagine stessa per scegliere una foto dalla galleria)", comment: " (cambia il colore dell'immagine di default cliccando sul pulsante al suo fianco, altrimenti clicca sull'immagine stessa per scegliere una foto dalla galleria)"))
    private var systemColors: [Color] = [.blue, .green, .yellow, .purple, .cyan, .brown, .gray, .orange, .pink, .indigo, .mint, .teal]
    
    var body: some View {
        VStack(spacing: 20) {
            Text(NSLocalizedString("Registrazione", comment: "Registrazione"))
                .font(.largeTitle)
                .bold()
            
            subtitle1 + subtitle2 + subtitle3 + subtitle4 + subtitle5 + subtitle6 + subtitle7
            
            ClearableTextField(hint: "Nome utente", text: $username, startIcon: "person", endIcon: "xmark.circle.fill", error: $usernameError)
            
            if usernameError {
                Text(NSLocalizedString("Inserisci un nome utente valido", comment: "Inserisci un nome utente valido"))
                    .foregroundColor(.red)
                    .padding(.vertical, -12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.footnote)
            }
            
            ClearableTextField(hint: "Nome visualizzato", text: $displayName, startIcon: "person.fill", endIcon: "xmark.circle.fill", error: $displayNameError)
            
            if displayNameError {
                Text(NSLocalizedString("Inserisci un nome visualizzato valido", comment: "Inserisci un nome visualizzato valido"))
                    .foregroundColor(.red)
                    .padding(.vertical, -12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.footnote)
            }
            
            if let image = profileImage {
                image
                    .resizable()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
            } else {
                ZStack {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .foregroundStyle(defaultPropicColor)
                        .onTapGesture {
                            // Aggiungi la logica per selezionare una nuova immagine di profilo
                        }
                    Button {
                        defaultPropicColor = systemColors.randomElement()!
                    } label: {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .resizable()
                            .frame(width: 36, height: 36)
                            .tint(defaultPropicColor)
                    }
                    .offset(x: 125, y: 0)
                }
            }
            
            Button(action: completeRegistration) {
                Text(NSLocalizedString("Completa registrazione", comment: "Bottone completa"))
                    .font(.title3)
                    .bold()
                    .frame(width: 250, height: 40)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal)
    }
    
    func completeRegistration() {
        usernameError = false
        displayNameError = false
        
        checkUsername()
        checkDisplayName()
        
        // Se tutto è valido, continua con il completamento della registrazione
        if !(usernameError || displayNameError) {
            // Aggiungi la logica per completare la registrazione
        }
    }
    
    func checkUsername() {
        guard !username.isEmpty else {
            usernameError = true
            return
        }
        // Puoi aggiungere ulteriori controlli qui, ad esempio verificare se il nome utente esiste già
    }
    
    func checkDisplayName() {
        guard !displayName.isEmpty else {
            displayNameError = true
            return
        }
    }
}

#Preview {
    CompleteRegistrationView()
        .accentColor(.cyan)
}
