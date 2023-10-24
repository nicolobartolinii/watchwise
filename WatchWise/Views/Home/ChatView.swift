//
//  ChatView.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 13/09/23.
//

import SwiftUI
import Kingfisher

struct ChatView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ChatViewModel
    @State private var messageContent: String = ""
    
    init(user: User, currentUserUid: String) {
        self.viewModel = ChatViewModel(user: user, currentUserUid: currentUserUid)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Color.clear
                        .background(.thinMaterial)
                    
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
                        .padding(.leading)
                        
                        KFImage(URL(string: viewModel.user.profilePath))
                            .resizable()
                            .clipShape(Circle())
                            .frame(width: 40, height: 40)
                            .scaledToFit()
                            .foregroundStyle(Color.primary)
                            .padding(.leading, 8)
                        
                        Text(viewModel.user.displayName)
                            .font(.title)
                            .foregroundColor(.accentColor)
                            .bold()
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                    }
                }
                .frame(height: 70)
                
                ScrollView {
                    ForEach(Array(viewModel.messages.enumerated()), id: \.offset) { index, message in
                        HStack {
                            if message.0.senderId == viewModel.currentUserUid {
                                Spacer()
                                VStack(spacing: 0) {
                                    SentMessageView(message: message)
                                    Text("Consigliato il \(Utils.formatDateToLocalStringShort(date: message.0.timestamp.dateValue()))")
                                        .frame(width: UIScreen.main.bounds.width / 1.5, alignment: .trailing)
                                        .foregroundStyle(Color.secondary)
                                        .font(.caption)
                                        .lineLimit(1)
                                        .padding(.trailing, 48)
                                        .offset(y: -20)
                                        .padding(.bottom, -20)
                                }
                            } else if message.0.senderId != viewModel.currentUserUid {
                                VStack(spacing: 0) {
                                    ReceivedMessageView(message: message)
                                    Text("Consigliato il \(Utils.formatDateToLocalStringShort(date: message.0.timestamp.dateValue()))")
                                        .frame(width: UIScreen.main.bounds.width / 1.5, alignment: .leading)
                                        .foregroundStyle(Color.secondary)
                                        .font(.caption)
                                        .lineLimit(1)
                                        .padding(.leading, 48)
                                        .offset(y: -20)
                                        .padding(.bottom, -20)
                                }
                                Spacer()
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width)
                    }
                }
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct SentMessageView: View {
    var message: (Message, Any)
    
    var body: some View {
        HStack {
            if let movie = message.1 as? Movie {
                if let posterPath = movie.poster_path {
                    KFImage(URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)"))
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width / 6, height: (UIScreen.main.bounds.width / 6) * 1.5)
                        .cornerRadius(10)
                        .shadow(color: .primary.opacity(0.2) , radius: 5)
                        .offset(x: 10)
                        .padding(-16)
                } else {
                    Image("error_404")
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width / 6, height: (UIScreen.main.bounds.width / 6) * 1.5)
                        .cornerRadius(10)
                        .shadow(color: .primary.opacity(0.2) , radius: 5)
                        .offset(x: 10)
                        .padding(-16)
                }
                HStack {
                    Spacer()
                        .frame(width: 50)
                    Text(movie.title)
                        .padding(.trailing, 56)
                        .frame(width: UIScreen.main.bounds.width / 1.5, alignment: .leading)
                        .padding()
                        .bold()
                        .foregroundStyle(Color.accentColor)
                        .font(.title3)
                        .lineLimit(1)
                }
                .frame(width: UIScreen.main.bounds.width / 1.5)
            } else if let show = message.1 as? TVShow {
                if let posterPath = show.posterPath {
                    KFImage(URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)"))
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width / 6, height: (UIScreen.main.bounds.width / 6) * 1.5)
                        .cornerRadius(10)
                        .shadow(color: .primary.opacity(0.2) , radius: 5)
                        .offset(x: 10)
                        .padding(-16)
                } else {
                    Image("error_404")
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width / 6, height: (UIScreen.main.bounds.width / 6) * 1.5)
                        .cornerRadius(10)
                        .shadow(color: .primary.opacity(0.2) , radius: 5)
                        .offset(x: 10)
                        .padding(-16)
                }
            }
        }
        .background {
            Capsule()
                .fill(Color(uiColor: .systemGray6))
                .frame(width: UIScreen.main.bounds.width / 1.5)
        }
        .frame(width: UIScreen.main.bounds.width / 1.5)
        .padding(.horizontal)
        .padding(.vertical, 24)
    }
}

struct ReceivedMessageView: View {
    var message: (Message, Any)
    
    var body: some View {
        HStack {
            if let movie = message.1 as? Movie {
                HStack {
                    Text(movie.title)
                        .padding(.leading, 56)
                        .frame(width: UIScreen.main.bounds.width / 1.5, alignment: .trailing)
                        .padding()
                        .bold()
                        .foregroundStyle(Color(uiColor: .systemBackground))
                        .font(.title3)
                        .lineLimit(1)
                    Spacer()
                        .frame(width: 50)
                }
                .frame(width: UIScreen.main.bounds.width / 1.5)
                if let posterPath = movie.poster_path {
                    KFImage(URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)"))
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width / 6, height: (UIScreen.main.bounds.width / 6) * 1.5)
                        .cornerRadius(10)
                        .shadow(color: .primary.opacity(0.2) , radius: 5)
                        .offset(x: -10)
                        .padding(-16)
                } else {
                    Image("error_404")
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width / 6, height: (UIScreen.main.bounds.width / 6) * 1.5)
                        .cornerRadius(10)
                        .shadow(color: .primary.opacity(0.2) , radius: 5)
                        .offset(x: -10)
                        .padding(-16)
                }
            } else if let show = message.1 as? TVShow {
                if let posterPath = show.posterPath {
                    KFImage(URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)"))
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width / 6, height: (UIScreen.main.bounds.width / 6) * 1.5)
                        .cornerRadius(10)
                        .shadow(color: .primary.opacity(0.2) , radius: 5)
                        .offset(x: -10)
                        .padding(-16)
                } else {
                    Image("error_404")
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width / 6, height: (UIScreen.main.bounds.width / 6) * 1.5)
                        .cornerRadius(10)
                        .shadow(color: .primary.opacity(0.2) , radius: 5)
                        .offset(x: -10)
                        .padding(-16)
                }
            }
        }
        .background {
            Capsule()
                .fill(Color.accentColor)
                .frame(width: UIScreen.main.bounds.width / 1.5)
        }
        .frame(width: UIScreen.main.bounds.width / 1.5)
        .padding(.horizontal)
        .padding(.vertical, 24)
    }
}
