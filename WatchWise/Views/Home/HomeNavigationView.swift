//
//  HomeNavigationView.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 19/08/23.
//

import SwiftUI
import AxisSegmentedView

struct HomeNavigationView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var tabSelection = 0
    
    var body: some View {
        TabView(selection: $tabSelection) {
            HomeView()
                .tabItem {
                    Label(NSLocalizedString("Home", comment: "Home"), systemImage: "house")
                }
                .tag(0)
            FeedView()
                .tabItem {
                    Label(NSLocalizedString("Feed", comment: "Feed"), systemImage: "bell")
                }
                .tag(1)
            SearchView()
                .tabItem {
                    Label(NSLocalizedString("Esplora", comment: "Esplora"), systemImage: "magnifyingglass")
                }
                .tag(2)
            EpisodesView(currentUserUid: authManager.currentUserUid)
                .tabItem {
                    Label(NSLocalizedString("Episodi", comment: "Episodi"), systemImage: "tv.inset.filled")
                }
                .tag(3)
            UserDetailsView(uid: authManager.currentUserUid, currentUserUid: authManager.currentUserUid)
                .tabItem {
                    Label(NSLocalizedString("Profilo", comment: "Profile"), systemImage: "person")
                }
                .tag(4)
                .environmentObject(authManager)
        }
    }
}

#Preview {
    HomeNavigationView()
}
