//
//  ChatsListView.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 13/09/23.
//

import SwiftUI
import Kingfisher

struct ChatsListView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ChatsListViewModel
    private var currentUserUid: String

    init(currentUserUid: String) {
        self.currentUserUid = currentUserUid
        self.viewModel = ChatsListViewModel(currentUserUid: currentUserUid)
    }
    
    var body: some View {
            NavigationStack {
                VStack(spacing: 0) {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "arrow.backward")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                                .padding(10)
                                .background(.thinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(LinearGradient(colors: [.primary.opacity(0.1), .primary.opacity(0.4), .primary.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                )
                                .cornerRadius(12)
                        }
                        Text("Chat")
                            .font(.title)
                            .foregroundColor(.accentColor)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                    }
                    .padding(.horizontal)
                    
                    List(viewModel.chats.indices, id: \.self) { index in
                        NavigationLink(value: viewModel.chats[index]) {
                            HStack {
                                KFImage(URL(string: viewModel.chats[index].user.profilePath))
                                    .resizable()
                                    .clipShape(Circle())
                                    .frame(width: 40, height: 40)
                                    .scaledToFit()
                                    .foregroundStyle(Color.primary)
                                VStack {
                                    Text(viewModel.chats[index].user.displayName)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundStyle(Color.primary)
                                        .fontWeight(.semibold)
                                    Text(viewModel.chats[index].user.username)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundStyle(Color.secondary)
                                }
                                Spacer()
                            }
                        }
                    }
                }
                .toolbar(.hidden, for: .navigationBar)
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: Chat.self) { chat in
                    ChatView(user: chat.user, currentUserUid: currentUserUid)
                        .toolbar(.hidden, for: .tabBar)
                }
            }
            .navigationBarBackButtonHidden(true)
            
        }
}
