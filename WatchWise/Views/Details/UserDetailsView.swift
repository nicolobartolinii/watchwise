//
//  UserDetailsView.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 31/08/23.
//

import SwiftUI
import Kingfisher

struct UserDetailsView: View {
    @EnvironmentObject var authManager: AuthManager
    @ObservedObject var viewModel: UserDetailsViewModel
    
    @State var offset: CGFloat = 0
    @State var showReviews = false
    
    @Environment(\.dismiss) var dismiss
    
    init(uid: String, currentUserUid: String) {
        self.viewModel = UserDetailsViewModel(uid: uid, currentUserUid: currentUserUid)
    }
    
    var body: some View {
        
        NavigationView {
            VStack {
                if let user = viewModel.user {
                    ZStack(alignment: .topLeading) {
                        OffsetScrollView(offset: $offset, showIndicators: true, axis: .vertical) {
                            BackgroundImageView(backdrop_path: user.backdropPath, offset: offset)
                            
                            KFImage(URL(string: user.profilePath))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipShape(Circle())
                                .offset(y: -75)
                                .shadow(color: Color.primary, radius: 5)
                            
                            Text(user.displayName)
                                .bold()
                                .font(.title2)
                                .offset(y: -70)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Text(user.username)
                                .fontWeight(.semibold)
                                .font(.title3)
                                .offset(y: -65)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Divider()
                                .offset(y: -55)
                            
                            if user.uid == authManager.currentUserUid {
                                HStack {
                                    Button(action: {  }) {
                                        HStack {
                                            Image(systemName: "pencil")
                                            Text("Modifica profilo")
                                                .bold()
                                        }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    Button(action: {  }) {
                                        HStack {
                                            Image(systemName: "gear")
                                            Text("Impostazioni app")
                                                .bold()
                                        }
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                                .offset(y: -45)
                            } else {
                                Button(action: {
                                    if viewModel.isFollowing {
                                        viewModel.unfollowUser()
                                    } else {
                                        viewModel.followUser()
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: viewModel.isFollowing ? "xmark" : "plus")
                                        Text(viewModel.isFollowing ? "Non seguire più".uppercased() : "Segui".uppercased())
                                            .bold()
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .offset(y: -45)
                            }
                            
                            Divider()
                                .offset(y: -35)
                            
                            Text("Informazioni")
                                .fontWeight(.semibold)
                                .font(.title3)
                                .foregroundColor(.accentColor)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                .offset(y: -30)
                            
                            ScrollView(.horizontal) {
                                HStack {
                                    TimeCard(title: "Tempo film", months: viewModel.movieMonths, days: viewModel.movieDays, hours: viewModel.movieHours)
                                    TimeCard(title: "Tempo TV", months: viewModel.tvMonths, days: viewModel.tvDays, hours: viewModel.tvHours)
                                    NumbersCard(title: "Film visti", number: user.movieNumber)
                                    NumbersCard(title: "Episodi visti", number: user.tvNumber)
                                    NumbersCard(title: "Followers", number: viewModel.followersCount)
                                    NumbersCard(title: "Seguiti", number: viewModel.followingCount)
                                }
                                .padding(.horizontal)
                            }
                            .offset(y: -40)
                            
                            Divider()
                                .offset(y: -35)
                            
                            Text("Liste")
                                .fontWeight(.semibold)
                                .font(.title3)
                                .foregroundColor(.accentColor)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                .offset(y: -30)
                            
                            ScrollView(.horizontal) {
                                HStack {
                                    NavigationLink(destination: ListDetailsView(listId: "favorite", currentUserUid: authManager.currentUserUid)) {
                                        ListCard(rawList: viewModel.rawLists.first(where: { $0.listId == "favorite" }) ?? ("", "", 0, ""))
                                    }
                                    NavigationLink(destination: ListDetailsView(listId: "watchlist", currentUserUid: authManager.currentUserUid)) {
                                        ListCard(rawList: viewModel.rawLists.first(where: { $0.listId == "watchlist" }) ?? ("", "", 0, ""))
                                    }
                                    NavigationLink(destination: ListDetailsView(listId: "watched_m", currentUserUid: authManager.currentUserUid)) {
                                        ListCard(rawList: viewModel.rawLists.first(where: { $0.listId == "watched_m" }) ?? ("", "", 0, ""))
                                    }
                                    NavigationLink(destination: ListDetailsView(listId: "watching_t", currentUserUid: authManager.currentUserUid)) {
                                        ListCard(rawList: viewModel.rawLists.first(where: { $0.listId == "watching_t" }) ?? ("", "", 0, ""))
                                    }
                                    NavigationLink(destination: ListDetailsView(listId: "finished_t", currentUserUid: authManager.currentUserUid)) {
                                        ListCard(rawList: viewModel.rawLists.first(where: { $0.listId == "finished_t" }) ?? ("", "", 0, ""))
                                    }
                                    
                                    VStack(spacing: 4) {
                                        Image(systemName: "plus")
                                            .font(.title)
                                            .bold()
                                            .foregroundStyle(Color.accentColor)
                                        
                                        Text("Crea una nuova lista".uppercased())
                                            .padding(.horizontal, 8)
                                            .font(.callout)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(width: 160, height: 105)
                                    .background(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(Utils.linearGradient)
                                    )
                                    .cornerRadius(12)
                                    .shadow(color: .primary.opacity(0.2) , radius: 3)
                                    .padding(.vertical, 8)
                                }
                                .padding(.horizontal)
                            }
                            .offset(y: -40)
                            
                            Divider()
                                .offset(y: -35)
                            
                            Text("Valutazioni e recensioni")
                                .fontWeight(.semibold)
                                .font(.title3)
                                .foregroundColor(.accentColor)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                .offset(y: -30)
                            
                            HistogramView(ratings: $viewModel.ratings)
                                .padding(.horizontal)
                                .offset(y: -20)
                            
                            if !viewModel.reviews.isEmpty {
                                Button {
                                    showReviews.toggle()
                                } label: {
                                    Text("Visualizza tutte le recensioni (\(viewModel.reviews.count))")
                                        .frame(height: 28)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal)
                                }
                                .sheet(isPresented: $showReviews) {
                                    NavigationView {
                                        if !viewModel.reviews.isEmpty {
                                            List(viewModel.reviews, id: \.productId) { review in
                                                NavigationLink(destination: review.type == "movie" ? AnyView(MovieDetailsView(movieId: review.productId, currentUserUid: authManager.currentUserUid)) : AnyView(TVShowDetailsView(showId: review.productId, currentUserUid: authManager.currentUserUid))) {
                                                    HStack(alignment: .top) {
                                                        if let posterPath = review.posterPath {
                                                            KFImage(URL(string: "https://image.tmdb.org/t/p/w154\(posterPath)"))
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(width: 60, height: 60)
                                                                .cornerRadius(8)
                                                                .padding(.leading, -8)
                                                        } else {
                                                            Image(.error404)
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(width: 60, height: 60)
                                                                .cornerRadius(8)
                                                                .padding(.leading, -8)
                                                        }
                                                        VStack {
                                                            Text("Data recensione: \(Utils.formatDateToLocalString(date: review.timestamp.dateValue()))")
                                                                .foregroundStyle(Color.secondary)
                                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                                .lineLimit(2)
                                                                .multilineTextAlignment(.leading)
                                                                .font(.footnote)
                                                            Text("\"\(review.text)\"")
                                                                .italic()
                                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                                .font(.subheadline)
                                                                .multilineTextAlignment(.leading)
                                                        }
                                                        .padding(.trailing, 5)
                                                    }
                                                }
                                            }
                                            .navigationTitle("Recensioni di \(user.displayName)")
                                        } else {
                                            ProgressView("Caricamento in corso...")
                                                .progressViewStyle(.circular)
                                                .tint(.accentColor)
                                                .controlSize(.large)
                                        }
                                    }
                                }
                                .offset(y: -5)
                            }
                        }
                        .ignoresSafeArea(edges: .top)
                        if user.uid != authManager.currentUserUid {
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
                        }
                    }
                } else {
                    ProgressView("Caricamento in corso...")
                        .progressViewStyle(.circular)
                        .tint(.accentColor)
                        .controlSize(.large)
                }
            }
            .onAppear {
                Task {
                    await viewModel.fetchUserDetails()
                }
            }
        .navigationBarBackButtonHidden(true)
        }
    }
}

struct TimeCard: View {
    var title: String
    var months: Int
    var days: Int
    var hours: Int
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title.uppercased())
                .fontWeight(.semibold)
                .padding(.top, 8)
                .padding(.horizontal)
                .font(.title3)
                .frame(height: 32)
            
            Utils.linearGradient
                .frame(maxWidth: .infinity, maxHeight: 1)
            
            HStack {
                VStack {
                    Text(Utils.convertSeasonEpisodeNumber(months))
                        .foregroundStyle(Color.accentColor)
                        .bold()
                        .font(.title2)
                    Text("mesi")
                        .foregroundStyle(Color.secondary)
                        .font(.callout)
                        .fontWeight(.light)
                }
                VStack {
                    Text(Utils.convertSeasonEpisodeNumber(days))
                        .foregroundStyle(Color.accentColor)
                        .bold()
                        .font(.title2)
                    Text("giorni")
                        .foregroundStyle(Color.secondary)
                        .font(.callout)
                        .fontWeight(.light)
                }
                VStack {
                    Text(Utils.convertSeasonEpisodeNumber(hours))
                        .foregroundStyle(Color.accentColor)
                        .bold()
                        .font(.title2)
                    Text("ore")
                        .foregroundStyle(Color.secondary)
                        .font(.callout)
                        .fontWeight(.light)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            .frame(height: 50)
            
            Spacer()
        }
        .frame(width: 160, height: 105)
        .background(.ultraThinMaterial)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Utils.linearGradient)
        )
        .cornerRadius(12)
        .shadow(color: .primary.opacity(0.2) , radius: 3)
        .padding(.vertical, 8)
    }
}

struct NumbersCard: View {
    var title: String
    var number: Int
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title.uppercased())
                .fontWeight(.semibold)
                .padding(.top, 8)
                .padding(.horizontal, 8)
                .font(.title3)
                .frame(height: 32)
            
            Utils.linearGradient
                .frame(maxWidth: .infinity, maxHeight: 1)
            
            Text("\(number)")
                .foregroundStyle(Color.accentColor)
                .bold()
                .font(.title)
                .padding(.horizontal)
                .padding(.vertical, 8)
            
            Spacer()
        }
        .frame(width: 160, height: 105)
        .background(.ultraThinMaterial)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Utils.linearGradient)
        )
        .cornerRadius(12)
        .shadow(color: .primary.opacity(0.2) , radius: 3)
        .padding(.vertical, 8)
    }
}

struct ListCard: View {
    var rawList: (type: String, name: String, totalCount: Int, listId: String)
    
    var body: some View {
        VStack(spacing: 4) {
            Text(rawList.name.uppercased())
                .fontWeight(.semibold)
                .padding(.top, 8)
                .padding(.horizontal, 8)
                .font(.headline)
                .frame(height: 32)
            
            Utils.linearGradient
                .frame(maxWidth: .infinity)
                .frame(height: 1)
            
            VStack(spacing: 0) {
                Text("\(rawList.totalCount)")
                    .foregroundStyle(Color.accentColor)
                    .bold()
                    .font(.title)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .frame(height: 40)
                
                Text(rawList.type == "movie" ? "film" : (rawList.type == "tv" ? "serie tv" : "film e/o serie TV"))
                    .font(.caption.smallCaps())
                    .fontWeight(.thin)
                    .foregroundStyle(Color.secondary)
            }
            
            Spacer()
        }
        .frame(width: 160, height: 105)
        .background(.ultraThinMaterial)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Utils.linearGradient)
        )
        .cornerRadius(12)
        .shadow(color: .primary.opacity(0.2) , radius: 3)
        .padding(.vertical, 8)
    }
}

struct UserDetailsView_Previews: PreviewProvider {
    static let authManager = AuthManager()
    
    static var previews: some View {
        UserDetailsView(uid: "egcf4FX5jDY5dbUeF3qZs1d6mQA3", currentUserUid: "aGPDrIy3oHbMOgoGykZKulO5L8w2")
            .environmentObject(authManager)
    }
}
