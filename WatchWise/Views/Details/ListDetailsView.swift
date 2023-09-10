//
//  ListDetailsView.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 09/09/23.
//

import SwiftUI
import Kingfisher

enum ProductTypeTab: String, CaseIterable {
    case movies = "Film"
    case tvShows = "Serie TV"
    
    var localized: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

struct ListDetailsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @StateObject var viewModel: ListDetailsViewModel
    
    @State var selectedProductTypeTab: ProductTypeTab = .movies
    
    init(listId: String, currentUserUid: String) {
        _viewModel = StateObject(wrappedValue: ListDetailsViewModel(listId: listId, currentUserUid: currentUserUid))
    }
    
    var body: some View {
        NavigationView {
            if viewModel.isLoaded {
                VStack {
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
                        
                        Text(viewModel.listName)
                            .foregroundStyle(Color.accentColor)
                            .font(.title)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    if viewModel.listType == "both" {
                        Picker("Film o serie TV", selection: $selectedProductTypeTab) {
                            ForEach(ProductTypeTab.allCases, id: \.self) { tab in
                                Text(tab.localized).tag(tab)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                    }
                    
                    switch selectedProductTypeTab {
                    case .movies:
                        ScrollView(.vertical) {
                            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 16) {
                                ForEach(viewModel.moviesList, id: \.id) { movie in
                                    NavigationLink(destination: MovieDetailsView(movieId: movie.id, currentUserUid: authManager.currentUserUid)) {
                                        if let posterPath = movie.poster_path {
                                            KFImage(URL(string: "https://image.tmdb.org/t/p/w185\(posterPath)"))
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: UIScreen.main.bounds.width / 3.5, height: (UIScreen.main.bounds.width / 3.5) * 1.5)
                                                .shadow(color: .primary.opacity(0.2) , radius: 5)
                                                .cornerRadius(10)
                                        } else {
                                            Image("error_404")
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: UIScreen.main.bounds.width / 3.5, height: (UIScreen.main.bounds.width / 3.5) * 1.5)
                                                .shadow(color: .primary.opacity(0.2) , radius: 5)
                                                .cornerRadius(10)
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                    case .tvShows:
                        ScrollView(.vertical) {
                            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 16) {
                                ForEach(viewModel.tvShowsList, id: \.id) { show in
                                    NavigationLink(destination: TVShowDetailsView(showId: show.id, currentUserUid: authManager.currentUserUid)) {
                                        if let posterPath = show.posterPath {
                                            KFImage(URL(string: "https://image.tmdb.org/t/p/w185\(posterPath)"))
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: UIScreen.main.bounds.width / 3.5, height: (UIScreen.main.bounds.width / 3.5) * 1.5)
                                                .shadow(color: .primary.opacity(0.2) , radius: 5)
                                                .cornerRadius(10)
                                        } else {
                                            Image("error_404")
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: UIScreen.main.bounds.width / 3.5, height: (UIScreen.main.bounds.width / 3.5) * 1.5)
                                                .shadow(color: .primary.opacity(0.2) , radius: 5)
                                                .cornerRadius(10)
                                        }
                                    }
                                }
                            }
                            .padding()
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
            Task {
                do {
                    try await viewModel.fetchProducts()
                    self.selectedProductTypeTab = viewModel.listType == "movie" || viewModel.listType == "both" ? .movies : .tvShows
                } catch {
                    print("Errore nel recuperare i prodotti: \(error)")
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
