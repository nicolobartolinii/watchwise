//
//  AuthenticationView.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 21/08/23.
//

import SwiftUI

import Combine

struct AuthenticationView: View {
  @EnvironmentObject var authManager: AuthManager

  var body: some View {
    VStack {
      switch authManager.flow {
      case .login:
        LoginView()
          .environmentObject(authManager)
          .accentColor(.cyan)
      case .signUp:
        EmailRegistrationView()
          .environmentObject(authManager)
          .accentColor(.cyan)
      }
    }
  }
}

struct AuthenticationView_Previews: PreviewProvider {
  static var previews: some View {
    AuthenticationView()
      .environmentObject(AuthManager())
  }
}
