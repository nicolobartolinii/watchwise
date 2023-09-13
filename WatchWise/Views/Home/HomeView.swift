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
    @EnvironmentObject var authManager: AuthManager
    @State private var nowPlayingMovies: [DiscoveredMovie]?
    @State private var topRatedMovies: [Movie] = []
    @State private var topRatedTVShows: [TVShow] = []
    
    var body: some View {
        NavigationView {
            if let nowPlayingMovies = nowPlayingMovies, !nowPlayingMovies.isEmpty {
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
                    
                    ScrollView(.vertical) {
                        Text("Ultime uscite")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(nowPlayingMovies, id: \.self) { movie in
                                    NavigationLink(destination: MovieDetailsView(movieId: movie.id, currentUserUid: authManager.currentUserUid)) {
                                        if let posterPath = movie.poster_path {
                                            KFImage(URL(string: "https://image.tmdb.org/t/p/w185\(posterPath)"))
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: UIScreen.main.bounds.width / 3, height: (UIScreen.main.bounds.width / 3) * 1.5)
                                                .shadow(color: .primary.opacity(0.2) , radius: 5)
                                                .cornerRadius(10)
                                        } else {
                                            Image("error_404")
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: UIScreen.main.bounds.width / 3, height: (UIScreen.main.bounds.width / 3) * 1.5)
                                                .shadow(color: .primary.opacity(0.2) , radius: 5)
                                                .cornerRadius(10)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Divider()
                        
                        Text("Film più graditi")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        if self.topRatedMovies.count != 0 {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(topRatedMovies, id: \.id) { movie in
                                        NavigationLink(destination: MovieDetailsView(movieId: movie.id, currentUserUid: authManager.currentUserUid)) {
                                            if let posterPath = movie.poster_path {
                                                KFImage(URL(string: "https://image.tmdb.org/t/p/w185\(posterPath)"))
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: UIScreen.main.bounds.width / 3, height: (UIScreen.main.bounds.width / 3) * 1.5)
                                                    .shadow(color: .primary.opacity(0.2) , radius: 5)
                                                    .cornerRadius(10)
                                            } else {
                                                Image("error_404")
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: UIScreen.main.bounds.width / 3, height: (UIScreen.main.bounds.width / 3) * 1.5)
                                                    .shadow(color: .primary.opacity(0.2) , radius: 5)
                                                    .cornerRadius(10)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        } else {
                            ProgressView("Caricamento in corso...")
                                .progressViewStyle(.circular)
                                .tint(.accentColor)
                                .controlSize(.large)
                        }
                        
                        Divider()
                        
                        Text("Serie TV più gradite")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        if self.topRatedTVShows.count != 0 {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(topRatedTVShows, id: \.id) { show in
                                        NavigationLink(destination: TVShowDetailsView(showId: show.id, currentUserUid: authManager.currentUserUid)) {
                                            if let posterPath = show.posterPath {
                                                KFImage(URL(string: "https://image.tmdb.org/t/p/w185\(posterPath)"))
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: UIScreen.main.bounds.width / 3, height: (UIScreen.main.bounds.width / 3) * 1.5)
                                                    .shadow(color: .primary.opacity(0.2) , radius: 5)
                                                    .cornerRadius(10)
                                            } else {
                                                Image("error_404")
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: UIScreen.main.bounds.width / 3, height: (UIScreen.main.bounds.width / 3) * 1.5)
                                                    .shadow(color: .primary.opacity(0.2) , radius: 5)
                                                    .cornerRadius(10)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        } else {
                            ProgressView("Caricamento in corso...")
                                .progressViewStyle(.circular)
                                .tint(.accentColor)
                                .controlSize(.large)
                        }
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
            getNowPlayingMovies()
            Task {
                await getTopRatedMoviesAndTVShows()
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
    
    func getTopRatedMoviesAndTVShows() async {
        do {
            let topRatedProducts = try await FirestoreService().getTopRatedMoviesAndTVShows()
            
            for movieId in topRatedProducts["movies"] ?? [] {
                APIManager.getMovieDetails(movieId: movieId) { (result: AFResult<Movie>) in
                    switch result {
                    case .success(let movie):
                        self.topRatedMovies.append(movie)
                    case .failure(let error):
                        print("Errore durante l'ottenimento dei dettagli del film \(movieId): \(error)")
                    }
                }
            }
            
            for showId in topRatedProducts["tv"] ?? [] {
                APIManager.getTVShowDetails(showId: showId) { (result: AFResult<TVShow>) in
                    switch result {
                    case .success(let show):
                        self.topRatedTVShows.append(show)
                    case .failure(let error):
                        print("Errore durante l'ottenimento dei dettagli della serie \(showId): \(error)")
                    }
                }
            }
        } catch {
            print("Errore durante l'ottenimento delle classifiche: \(error)")
        }
    }
}
