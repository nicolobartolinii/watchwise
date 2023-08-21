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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                VStack {
                    Image(systemName: "number.circle.fill")
                        .resizable()
                        .frame(width: 100 , height: 100)
                        .foregroundColor(Color(.systemPink))
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                        .clipped()
                        .padding(4)
                        .overlay(Circle().stroke(Color.black, lineWidth: 2))
                    Text("Welcome to Favourites!")
                        .font(.title)
                }
            }
        }
    }
}
