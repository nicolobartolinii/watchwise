//
//  ProfileView.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 19/08/23.
//

import SwiftUI

struct ProfileView: View {
  @EnvironmentObject var authManager: AuthManager
  @Environment(\.dismiss) var dismiss
  @State var presentingConfirmationDialog = false

  private func deleteAccount() {
    Task {
      if await authManager.deleteAccount() == true {
        dismiss()
      }
    }
  }

  private func signOut() {
    authManager.signOut()
  }

  var body: some View {
    Form {
      Section {
        VStack {
          HStack {
            Spacer()
            Image(systemName: "person.fill")
              .resizable()
              .frame(width: 100 , height: 100)
              .aspectRatio(contentMode: .fit)
              .clipShape(Circle())
              .clipped()
              .padding(4)
              .overlay(Circle().stroke(Color.accentColor, lineWidth: 2))
            Spacer()
          }
          Button(action: {}) {
            Text("edit")
          }
        }
      }
      .listRowBackground(Color(UIColor.systemGroupedBackground))
      Section("Email") {
        Text(authManager.displayName)
      }
      Section {
        Button(role: .cancel, action: signOut) {
          HStack {
            Spacer()
            Text("Sign out")
            Spacer()
          }
        }
      }
      Section {
        Button(role: .destructive, action: { presentingConfirmationDialog.toggle() }) {
          HStack {
            Spacer()
            Text("Delete Account")
            Spacer()
          }
        }
      }
    }
    .navigationTitle("Profile")
    .navigationBarTitleDisplayMode(.inline)
    .confirmationDialog("Deleting your account is permanent. Do you want to delete your account?",
                        isPresented: $presentingConfirmationDialog, titleVisibility: .visible) {
      Button("Delete Account", role: .destructive, action: deleteAccount)
      Button("Cancel", role: .cancel, action: { })
    }
  }
}

struct ProfileView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      ProfileView()
        .environmentObject(AuthManager())
    }
  }
}
