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
    
    init(uid: String) {
        self.viewModel = UserDetailsViewModel(uid: uid)
    }
    
    var body: some View {
        
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
                            Button(action: {  }) {
                                HStack {
                                    Image(systemName: "plus")
                                    Text("Segui".uppercased())
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
                                TimeCard(title: "Tempo film", times: [0, 0, 0])
                                TimeCard(title: "Tempo TV", times: [0, 0, 0])
                                NumbersCard(title: "Film visti", number: 0)
                                NumbersCard(title: "Episodi visti", number: 0)
                                NumbersCard(title: "Followers", number: 0)
                                NumbersCard(title: "Seguiti", number: 0)
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
                                ListCard(title: "Preferiti", items: [])
                                ListCard(title: "Watchlist", items: [])
                                ListCard(title: "Film visti", items: [])
                                ListCard(title: "Serie in visione", items: [])
                                ListCard(title: "Completate", items: [])
                                
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
                        
                        HistogramView(ratings: [])
                            .padding(.horizontal)
                            .offset(y: -20)
                        
                        
                        Button {
                            showReviews.toggle()
                        } label: {
                            Text("Visualizza tutte le recensioni (19)")
                                .frame(height: 28)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                        }
                        .sheet(isPresented: $showReviews) {
                            List {
                                VStack {
                                    Text("Recensione 1")
                                    Text("Recensione 2")
                                }
                            }
                        }
                        .offset(y: -5)
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
            viewModel.fetchUserDetails()
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct TimeCard: View {
    var title: String
    var times: [Int]
    
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
                    Text(Utils.convertSeasonEpisodeNumber(times[0]))
                        .foregroundStyle(Color.accentColor)
                        .bold()
                        .font(.title2)
                    Text("mesi")
                        .foregroundStyle(Color.secondary)
                        .font(.callout)
                        .fontWeight(.light)
                }
                VStack {
                    Text(Utils.convertSeasonEpisodeNumber(times[0]))
                        .foregroundStyle(Color.accentColor)
                        .bold()
                        .font(.title2)
                    Text("giorni")
                        .foregroundStyle(Color.secondary)
                        .font(.callout)
                        .fontWeight(.light)
                }
                VStack {
                    Text(Utils.convertSeasonEpisodeNumber(times[0]))
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
    var title: String
    var items: [Any]
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title.uppercased())
                .fontWeight(.semibold)
                .padding(.top, 8)
                .padding(.horizontal, 8)
                .font(.headline)
                .frame(height: 32)
            
            Utils.linearGradient
                .frame(maxWidth: .infinity, maxHeight: 1)
            
            Text("WIP")
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

struct UserDetailsView_Previews: PreviewProvider {
    static let authManager = AuthManager()
    
    static var previews: some View {
        UserDetailsView(uid: "aGPDrIy3oHbMOgoGykZKulO5L8w2")
            .environmentObject(authManager)
    }
}
