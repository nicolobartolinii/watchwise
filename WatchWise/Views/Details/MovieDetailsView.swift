//
//  MovieDetailsView.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 19/08/23.
//

import SwiftUI
import Alamofire
import Kingfisher

struct MovieDetailsView: View {
    let movieId: Int64
    @State private var movie: Movie?
    
    @State private var navBarHidden: Bool = true

        var body: some View {
            NavigationView {
                GeometryReader { geometry in
                    ScrollView(showsIndicators: false) {
                        VStack {
                            ZStack(alignment: .bottom) {
                                // Backdrop
                                if let backdropPath = movie?.backdrop_path {
                                    KFImage(URL(string: "https://image.tmdb.org/t/p/w500\(backdropPath)"))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: geometry.size.width, height: geometry.size.width * 0.6)
                                        .clipped()
                                        .ignoresSafeArea()
                                }

                                // Sfumatura
                                LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.0), Color.black.opacity(0.75)]), startPoint: .center, endPoint: .bottom)
                                    .frame(width: geometry.size.width, height: geometry.size.width * 0.6)
                            }

                            HStack {
                                // Poster
                                if let posterPath = movie?.poster_path {
                                    KFImage(URL(string: "https://image.tmdb.org/t/p/w185\(posterPath)"))
                                        .resizable()
                                        .aspectRatio(2/3, contentMode: .fit)
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                        .padding()
                                }

                                VStack(alignment: .leading) {
                                    // Dettagli film
                                    Text(movie?.title ?? "")
                                        .font(.headline)
                                    // Altre informazioni come regista, durata, ecc...
                                }
                                .padding(.leading)
                            }

                            // Trama, recensioni, cast, ecc...
                            Text("Lorem ipsum")
                            Text("Lorem ipsum")
                            Text("Lorem ipsum")
                        }
                    }
                    .background(NavigationLink("", destination: Text("Details").onAppear {
                        self.navBarHidden = false
                    }))
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                        self.navBarHidden = false
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                        self.navBarHidden = true
                    }
                }
                .navigationBarTitle(movie?.title ?? "", displayMode: .inline)
                .navigationBarHidden(navBarHidden)
            }
            .onAppear {
                getMovieDetails()
            }
        }
    
    func getMovieDetails() {
        APIManager.getMovieDetails(movieId: self.movieId) { (result: AFResult<Movie>) in
            switch result {
            case .success(let movie):
                self.movie = movie
            case .failure(let error):
                print("Error getting movie details: \(error)")
            }
            
        }
    }
}

#Preview {
    MovieDetailsView(movieId: 299534)
}
