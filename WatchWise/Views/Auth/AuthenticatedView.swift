//
//  AuthenticatedView.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 21/08/23.
//

import SwiftUI

extension AuthenticatedView where Unauthenticated == EmptyView {
    init(@ViewBuilder content: @escaping () -> Content) {
        self.unauthenticated = nil
        self.content = content
    }
}

struct AuthenticatedView<Content, Unauthenticated>: View where Content: View, Unauthenticated: View {
    @StateObject private var authManager = AuthManager()
    @State private var presentingLoginScreen = false
    @State private var presentingProfileScreen = false
    
    var unauthenticated: Unauthenticated?
    @ViewBuilder var content: () -> Content
    
    public init(unauthenticated: Unauthenticated?, @ViewBuilder content: @escaping () -> Content) {
        self.unauthenticated = unauthenticated
        self.content = content
    }
    
    public init(@ViewBuilder unauthenticated: @escaping () -> Unauthenticated, @ViewBuilder content: @escaping () -> Content) {
        self.unauthenticated = unauthenticated()
        self.content = content
    }
    
    
    var body: some View {
        switch authManager.authenticationState {
        case .unauthenticated, .authenticating:
            VStack {
                if let unauthenticated {
                    unauthenticated
                }
                else {
                    Text("You're not logged in.")
                }
                Button("Tap here to log in") {
                    authManager.reset()
                    presentingLoginScreen.toggle()
                }
            }
            .sheet(isPresented: $presentingLoginScreen) {
                AuthenticationView()
                    .environmentObject(authManager)
            }
        case .authenticated, .openingApp:
            EmptyView()
        }
    }
}

struct AuthenticatedView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticatedView {
            Text("You're signed in.")
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .background(.yellow)
        }
    }
}
