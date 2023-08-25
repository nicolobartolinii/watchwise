//
//  HomeView.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 16/08/23.
//

import SwiftUI
import Kingfisher
import FirebaseAuth
import Alamofire

struct HomeView: View {
    @State private var nowPlayingMovies: [DiscoveredMovie]?
    
    var body: some View {
        NavigationView {
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
                
                Text("Home")
                    .font(.title)
                    .foregroundColor(.accentColor)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                Text("Ultime uscite")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(nowPlayingMovies ?? [], id: \.self) { movie in
                            NavigationLink(destination: MovieDetailsView(movieId: movie.id)) {
                                KFImage(URL(string: "https://image.tmdb.org/t/p/w185\(movie.poster_path ?? "")"))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: UIScreen.main.bounds.width / 3, height: (UIScreen.main.bounds.width / 3) * 1.5)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                
            }
            .onAppear {
                getNowPlayingMovies()
            }
        }
    }
    
    func getNowPlayingMovies() {
        APIManager.getNowPlayingMovies { (result: AFResult<DiscoverMoviesResponse>) in
            switch result {
            case .success(let movies):
                self.nowPlayingMovies = movies.results
                print("Now playing movies count: \(movies.results.count)")
            case .failure(let error):
                print("Error getting now playing movies: \(error)")
            }
        }
    }
}

#Preview {
    HomeView()
}
