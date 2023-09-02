//
//  SearchView.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 19/08/23.
//

import SwiftUI
import Alamofire
import Kingfisher
import Combine

enum SearchTabs: String, CaseIterable {
    case movies = "Film"
    case shows = "Serie TV"
    case people = "Persone"
    case users = "Utenti"
    
    var localized: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

struct SearchView: View {
    @EnvironmentObject var authManager: AuthManager
    
    @State private var searchText: String = ""
    @State private var moviesTask: Task<Void, Never>?
    @State private var showsTask: Task<Void, Never>?
    @State private var peopleTask: Task<Void, Never>?
    @State private var usersTask: Task<Void, Never>?
    
    @State private var popularMovies: [DiscoveredMovie]?
    @State private var popularTVShows: [DiscoveredTVShow]?
    @State private var trendingMovies: [DiscoveredMovie]?
    @State private var trendingTVShows: [DiscoveredTVShow]?
    @State private var searchMoviesResults: [DiscoveredMovie]?
    @State private var searchShowsResults: [DiscoveredTVShow]?
    @State private var searchPeopleResults: [DiscoveredPerson]?
    @State private var searchUsersResults: [User]?
    
    @State private var showSearchResults = false
    @State private var isPressed = false
    
    @State private var selectedSearchTab = SearchTabs.movies
    
    @State private var isLoading: Bool = false
    
    @State private var currentMoviesPage: Int32 = 1
    @State private var currentShowsPage: Int32 = 1
    @State private var currentPeoplePage: Int32 = 1
    
    var body: some View {
        NavigationView {
            if let popularMovies = popularMovies, let popularTVShows = popularTVShows, let trendingMovies = trendingMovies, let trendingTVShows = trendingTVShows {
                VStack {
                    HStack(spacing: 16) {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35)
                        
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .frame(width: 24, height: 24)
                            TextField("Ricerca film, serie TV, persone o utenti", text: $searchText, axis: .horizontal)
                                .keyboardType(.default)
                                .textInputAutocapitalization(.sentences)
                                .autocorrectionDisabled(false)
                                .onChange(of: searchText) { newValue in
                                    if newValue != "" {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            showSearchResults = true
                                        }
                                        searchMoviesResults = []
                                        currentMoviesPage = 1
                                        searchShowsResults = []
                                        currentShowsPage = 1
                                        searchPeopleResults = []
                                        currentPeoplePage = 1
                                        searchUsersResults = []
                                        searchMovies(query: newValue, page: currentMoviesPage)
                                        searchShows(query: newValue, page: currentShowsPage)
                                        searchPeople(query: newValue, page: currentPeoplePage)
                                        searchUsers(query: newValue.lowercased())
                                    } else {
                                        withAnimation(.easeInOut(duration: 0.1)) {
                                            showSearchResults = false
                                        }
                                        searchMoviesResults = []
                                        currentMoviesPage = 1
                                        searchShowsResults = []
                                        currentShowsPage = 1
                                        searchPeopleResults = []
                                        currentPeoplePage = 1
                                        searchUsersResults = []
                                        selectedSearchTab = .movies
                                    }
                                }
                            if !searchText.isEmpty {
                                Button(action: {
                                    self.searchText = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .scaleEffect(isPressed ? 0.7 : 1)
                                        .animation(.easeInOut(duration: 0.2), value: isPressed)
                                        .frame(width: 24, height: 24)
                                }
                                .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
                                    self.isPressed = pressing
                                }, perform: {})
                            }
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.gray, lineWidth: 1))
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    
                    ZStack {
                        ScrollView(.vertical) {
                            VStack {
                                Text("Film popolari")
                                    .font(.title2)
                                    .foregroundColor(.accentColor)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(popularMovies, id: \.self) { movie in
                                            NavigationLink(destination: MovieDetailsView(movieId: movie.id)) {
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
                                
                                Text("Serie TV popolari")
                                    .font(.title2)
                                    .foregroundColor(.accentColor)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(popularTVShows, id: \.self) { show in
                                            NavigationLink(destination: TVShowDetailsView(showId: show.id)) {
                                                if let posterPath = show.poster_path {
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
                                
                                Text("Film di tendenza")
                                    .font(.title2)
                                    .foregroundColor(.accentColor)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(trendingMovies, id: \.self) { movie in
                                            NavigationLink(destination: MovieDetailsView(movieId: movie.id)) {
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
                                
                                Text("Serie TV di tendenza")
                                    .font(.title2)
                                    .foregroundColor(.accentColor)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(trendingTVShows, id: \.self) { show in
                                            NavigationLink(destination: TVShowDetailsView(showId: show.id)) {
                                                if let posterPath = show.poster_path {
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
                            }
                        }
                        if showSearchResults {
                            VStack(spacing: 0) {
                                
                                Picker("Ambiti di ricerca", selection: $selectedSearchTab) {
                                    ForEach(SearchTabs.allCases, id: \.self) { tab in
                                        Text(tab.localized).tag(tab)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .padding()
                                
                                switch selectedSearchTab {
                                case .movies:
                                    List {
                                        if !(searchMoviesResults?.isEmpty ?? false) {
                                            ForEach(searchMoviesResults ?? [], id: \.self) { movie in
                                                NavigationLink(destination: MovieDetailsView(movieId: movie.id)) {
                                                    HStack {
                                                        if let posterPath = movie.poster_path {
                                                            KFImage(URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)"))
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(width: 50, height: 50)
                                                                .cornerRadius(8)
                                                                .padding(.leading, -8)
                                                        } else {
                                                            Image("error_404")
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(width: 50, height: 50)
                                                                .cornerRadius(8)
                                                                .padding(.leading, -8)
                                                        }
                                                        Text(movie.title)
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                            .lineLimit(2)
                                                            .padding(.trailing)
                                                    }
                                                }
                                            }
                                        } else {
                                            if isLoading {
                                                ProgressView()
                                                    .frame(maxWidth: .infinity, alignment: .center)
                                                    .listRowBackground(Color.clear)
                                            } else {
                                                Text("Nessun risultato")
                                            }
                                        }
                                        
                                        Section("") {
                                            if let _ = searchMoviesResults?.last {
                                                Color.clear
                                                    .listRowBackground(Color.clear)
                                                    .onAppear {
                                                        loadMoreMovies()
                                                    }
                                            }
                                        }
                                    }
                                    .scrollContentBackground(.hidden)
                                case .shows:
                                    List {
                                        if !(searchShowsResults?.isEmpty ?? false) {
                                            ForEach(searchShowsResults ?? [], id: \.self) { show in
                                                NavigationLink(destination: TVShowDetailsView(showId: show.id)) {
                                                    HStack {
                                                        if let posterPath = show.poster_path {
                                                            KFImage(URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)"))
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(width: 50, height: 50)
                                                                .cornerRadius(8)
                                                                .padding(.leading, -8)
                                                        } else {
                                                            Image("error_404")
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(width: 50, height: 50)
                                                                .cornerRadius(8)
                                                                .padding(.leading, -8)
                                                        }
                                                        Text(show.name)
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                            .lineLimit(2)
                                                            .padding(.trailing)
                                                    }
                                                }
                                            }
                                        } else {
                                            if isLoading {
                                                ProgressView()
                                                    .frame(maxWidth: .infinity, alignment: .center)
                                                    .listRowBackground(Color.clear)
                                            } else {
                                                Text("Nessun risultato")
                                            }
                                        }
                                        
                                        Section("") {
                                            
                                            if let _ = searchShowsResults?.last {
                                                Color.clear
                                                    .listRowBackground(Color.clear)
                                                    .onAppear {
                                                        loadMoreShows()
                                                    }
                                            }
                                        }
                                    }
                                    .scrollContentBackground(.hidden)
                                case .people:
                                    List {
                                        if !(searchPeopleResults?.isEmpty ?? false) {
                                            ForEach(searchPeopleResults ?? [], id: \.self) { person in
                                                NavigationLink(destination: PersonDetailsView(personId: person.id)) {
                                                    HStack {
                                                        if let profilePath = person.profile_path {
                                                            KFImage(URL(string: "https://image.tmdb.org/t/p/w500\(profilePath)"))
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(width: 50, height: 50)
                                                                .cornerRadius(8)
                                                                .padding(.leading, -8)
                                                        } else {
                                                            Image("error_404")
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(width: 50, height: 50)
                                                                .cornerRadius(8)
                                                                .padding(.leading, -8)
                                                        }
                                                        Text(person.name)
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                            .lineLimit(2)
                                                            .padding(.trailing)
                                                    }
                                                }
                                            }
                                        } else {
                                            if isLoading {
                                                ProgressView()
                                                    .frame(maxWidth: .infinity, alignment: .center)
                                                    .listRowBackground(Color.clear)
                                            } else {
                                                Text("Nessun risultato")
                                            }
                                        }
                                        
                                        Section("") {
                                            
                                            
                                            if let _ = searchPeopleResults?.last {
                                                Color.clear
                                                    .listRowBackground(Color.clear)
                                                    .onAppear {
                                                        loadMorePeople()
                                                    }
                                            }
                                        }
                                    }
                                    .scrollContentBackground(.hidden)
                                default:
                                    List {
                                        if !(searchUsersResults?.isEmpty ?? false) {
                                            ForEach(searchUsersResults ?? [], id: \.uid) { user in
                                                NavigationLink(destination: UserDetailsView(uid: user.uid)) {
                                                    HStack {
                                                        KFImage(URL(string: user.profilePath))
                                                            .resizable()
                                                            .clipShape(Circle())
                                                            .scaledToFill()
                                                            .frame(width: 50, height: 50)
                                                            .cornerRadius(8)
                                                            .padding(.leading, -8)
                                                        VStack {
                                                            Text(user.username)
                                                                .fontWeight(.semibold)
                                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                                .lineLimit(1)
                                                            Text(user.displayName)
                                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                                .lineLimit(1)
                                                                .foregroundStyle(Color.secondary)
                                                        }
                                                        .padding(.trailing)
                                                    }
                                                }
                                            }
                                        } else {
                                            if isLoading {
                                                ProgressView()
                                                    .frame(maxWidth: .infinity, alignment: .center)
                                                    .listRowBackground(Color.clear)
                                            } else {
                                                Text("Nessun risultato")
                                            }
                                        }
                                    }
                                    .scrollContentBackground(.hidden)
                                }
                                
                                
                            }
                            .background(.regularMaterial)
                            .overlay(
                                UnevenRoundedRectangle(topLeadingRadius: 12, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 12, style: .continuous)
                                    .strokeBorder(linearGradient)
                            )
                            .clipShape(
                                UnevenRoundedRectangle(topLeadingRadius: 12, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 12, style: .continuous)
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                            .transition(.move(edge: .bottom))
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
            getPopularMovies()
            getPopularTVShows()
            getTrendingMovies()
            getTrendingTVShows()
        }
    }
    
    var linearGradient: LinearGradient {
        LinearGradient(colors: [.primary.opacity(0.1), .primary.opacity(0.3), .primary.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    func getPopularMovies() {
        APIManager.getPopularMovies { (result: AFResult<DiscoverMoviesResponse>) in
            switch result {
            case .success(let movies):
                self.popularMovies = movies.results
            case .failure(let error):
                print("Error getting now playing movies: \(error)")
            }
        }
    }
    
    func getPopularTVShows() {
        APIManager.getPopularTVShows { (result: AFResult<DiscoverTVShowsResponse>) in
            switch result {
            case .success(let shows):
                self.popularTVShows = shows.results
            case .failure(let error):
                print("Error getting now playing movies: \(error)")
            }
        }
    }
    
    func getTrendingMovies() {
        APIManager.getTrendingMovies { (result: AFResult<DiscoverMoviesResponse>) in
            switch result {
            case .success(let movies):
                self.trendingMovies = movies.results
            case .failure(let error):
                print("Error getting now playing movies: \(error)")
            }
        }
    }
    
    func getTrendingTVShows() {
        APIManager.getTrendingTVShows { (result: AFResult<DiscoverTVShowsResponse>) in
            switch result {
            case .success(let shows):
                self.trendingTVShows = shows.results
            case .failure(let error):
                print("Error getting now playing movies: \(error)")
            }
        }
    }
    
    func searchMovies(query: String, page: Int32) {
        // Annulla il lavoro di ricerca precedente, se esiste.
        moviesTask?.cancel()
        
        // Crea un nuovo lavoro di ricerca.
        moviesTask = Task {
            await performMoviesSearch(for: query, page: page)
        }
    }
    
    private func performMoviesSearch(for query: String, page: Int32) async {
        do {
            isLoading = true
            try await Task.sleep(nanoseconds: 1_000_000_000)
            APIManager.searchMovies(query: query, page: page) { (result: AFResult<DiscoverMoviesResponse>) in
                isLoading = false
                switch result {
                case .success(let movies):
                    searchMoviesResults = movies.results
                case .failure(let error):
                    print("Error searching movies: \(error)")
                }
            }
        } catch {
            print(error)
        }
    }
    
    func loadMoreMovies() {
        guard !isLoading else {
            return
        }
        
        isLoading = true
        currentMoviesPage += 1
        APIManager.searchMovies(query: searchText, page: currentMoviesPage) { (result: AFResult<DiscoverMoviesResponse>) in
            isLoading = false
            switch result {
            case .success(let movies):
                if currentMoviesPage <= movies.total_pages {
                    searchMoviesResults!.append(contentsOf: movies.results)
                }
            case .failure(let error):
                print("Error searching movies: \(error)")
            }
        }
    }
    
    func searchShows(query: String, page: Int32) {
        // Annulla il lavoro di ricerca precedente, se esiste.
        showsTask?.cancel()
        
        // Crea un nuovo lavoro di ricerca.
        showsTask = Task {
            await performShowsSearch(for: query, page: page)
        }
    }
    
    private func performShowsSearch(for query: String, page: Int32) async {
        do {
            isLoading = true
            try await Task.sleep(nanoseconds: 1_000_000_000)
            APIManager.searchShows(query: query, page: page) { (result: AFResult<DiscoverTVShowsResponse>) in
                isLoading = false
                switch result {
                case .success(let shows):
                    searchShowsResults = shows.results
                case .failure(let error):
                    print("Error searching movies: \(error)")
                }
            }
        } catch {
            print(error)
        }
    }
    
    func loadMoreShows() {
        guard !isLoading else {
            return
        }
        
        isLoading = true
        currentShowsPage += 1
        APIManager.searchShows(query: searchText, page: currentShowsPage) { (result: AFResult<DiscoverTVShowsResponse>) in
            isLoading = false
            switch result {
            case .success(let shows):
                if currentShowsPage <= shows.total_pages {
                    searchShowsResults!.append(contentsOf: shows.results)
                }
            case .failure(let error):
                print("Error searching movies: \(error)")
            }
        }
    }
    
    func searchPeople(query: String, page: Int32) {
        // Annulla il lavoro di ricerca precedente, se esiste.
        peopleTask?.cancel()
        
        // Crea un nuovo lavoro di ricerca.
        peopleTask = Task {
            await performPeopleSearch(for: query, page: page)
        }
    }
    
    private func performPeopleSearch(for query: String, page: Int32) async {
        do {
            isLoading = true
            try await Task.sleep(nanoseconds: 1_000_000_000)
            APIManager.searchPeople(query: query, page: page) { (result: AFResult<DiscoverPeopleResponse>) in
                isLoading = false
                switch result {
                case .success(let people):
                    searchPeopleResults = people.results
                case .failure(let error):
                    print("Error searching movies: \(error)")
                }
            }
        } catch {
            print(error)
        }
    }
    
    func loadMorePeople() {
        guard !isLoading else {
            return
        }
        
        isLoading = true
        currentPeoplePage += 1
        APIManager.searchPeople(query: searchText, page: currentPeoplePage) { (result: AFResult<DiscoverPeopleResponse>) in
            isLoading = false
            switch result {
            case .success(let people):
                if currentPeoplePage <= people.total_pages {
                    searchPeopleResults!.append(contentsOf: people.results)
                }
            case .failure(let error):
                print("Error searching movies: \(error)")
            }
        }
    }
    
    func searchUsers(query: String) {
        // Annulla il lavoro di ricerca precedente, se esiste.
        usersTask?.cancel()
        
        // Crea un nuovo lavoro di ricerca.
        usersTask = Task {
            await performUsersSearch(for: query)
        }
    }
    
    private func performUsersSearch(for query: String) async {
        do {
            isLoading = true
            try await Task.sleep(nanoseconds: 1_000_000_000)
            FirestoreService().searchUsers(by: query, currentUserUid: authManager.currentUserUid) { users in
                searchUsersResults = users
            }
        } catch {
            print(error)
        }
    }
}

#Preview {
    SearchView()
}
