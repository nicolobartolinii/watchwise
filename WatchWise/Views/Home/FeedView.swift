//
//  FeedView.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 19/08/23.
//

import SwiftUI

struct FeedView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationView {
            if let nowPlayingMovies = Int64("3") {
                VStack(spacing: 8) {
                    HStack {
                        Spacer()
                        HStack {
                            Image("logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35)
                            
                            Image("title")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150)
                        }
                        Spacer()
                    }
                    .frame(width: UIScreen.main.bounds.width - 100)
                    .padding(.horizontal, 5)
                    
                    HStack {
                        Text("Feed")
                            .font(.title)
                            .foregroundColor(.accentColor)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        Spacer()
                        
                        NavigationLink(destination: ChatsListView(currentUserUid: authManager.currentUserUid)) {
                            Image(systemName: "bubble.left.and.bubble.right")
                                .font(.title3)
                                .foregroundStyle(Color.accentColor)
                                .bold()
                                .padding(.horizontal)
                        }
                    }
                    
                    List() {
                        
                    }
                }
            }
        }
    }
}

#Preview {
    FeedView()
}
