//
//  WatchWiseApp.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 15/08/23.
//

import SwiftUI
import SwiftData
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
    // register app delegate for Firebase setup
      @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate


      var body: some Scene {
        WindowGroup {
          NavigationView {
            ContentView()
          }
        }
      }
}
