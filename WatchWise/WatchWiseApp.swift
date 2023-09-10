//
//  WatchWiseApp.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 15/08/23.
//

import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct WatchWiseApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var authManager = AuthManager()
    var body: some Scene {
        WindowGroup {
            switch authManager.authenticationState {
            case .unauthenticated, .authenticating:
                AuthenticationView()
                    .environmentObject(authManager)
            case .authenticated:
                HomeNavigationView()
                    .environmentObject(authManager)
            case .openingApp:
                SplashScreen()
            }
        }
    }
}
