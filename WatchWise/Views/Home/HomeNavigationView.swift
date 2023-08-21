//
//  HomeNavigationView.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 19/08/23.
//

import SwiftUI

struct HomeNavigationView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var tabSelection = 0
    
    var body: some View {
        TabView(selection: $tabSelection) {
            HomeView()
                .tabItem {
                    Label(NSLocalizedString("Home", comment: "Home"), systemImage: "house")
                }
            FeedView()
                .accentColor(.cyan)
                .tabItem {
                    Label(NSLocalizedString("Feed", comment: "Feed"), systemImage: "bell")
                }
            SearchView()
                .accentColor(.cyan)
                .tabItem {
                    Label(NSLocalizedString("Esplora", comment: "Esplora"), systemImage: "magnifyingglass")
                }
            EpisodesView()
                .accentColor(.cyan)
                .tabItem {
                    Label(NSLocalizedString("Episodi", comment: "Episodi"), systemImage: "tv.inset.filled")
                }
            ProfileView()
                .accentColor(.cyan)
                .tabItem {
                    Label(NSLocalizedString("Profilo", comment: "Profile"), systemImage: "person")
                }
                .environmentObject(authManager)
        }
        .animation(.easeInOut, value: tabSelection)
        .transition(.slide)
    }
}

#Preview {
    HomeNavigationView()
        .accentColor(.cyan)
}

