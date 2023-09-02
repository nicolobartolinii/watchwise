//
//  MovieDetailsView.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 19/08/23.
//

import SwiftUI
import Alamofire
import Kingfisher
import ExpandableText
import AxisRatingBar

enum InfoTabs: String, CaseIterable {
    case cast = "Cast"
    case crew = "Staff"
    case details = "Dettagli"
    case videos = "Video"
    
    var localized: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

struct MovieDetailsView: View {
    let movieId: Int64
    @State private var movie: Movie?
    
    @State private var navBarHidden: Bool = true
    
    @State var offset: CGFloat = 0
    
    @State var rating: CGFloat = 0.0
    
    @State private var showReviews = false
    
    @State private var unitType: Int = 1
    
    @State private var review = ""
    
    @State private var reviewError = false
    
    @State private var selectedInfoTab = InfoTabs.cast
    
    @State private var showNavigationBar: Bool = false
    
    
    @State private var tableContentHeight: CGFloat = 0
    @State private var observation: NSKeyValueObservation?
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isInWatched = false
    
    @State private var isInWatchlist = false
    
    @State private var isInFavorites = false
    
    @State private var isListsSharePresented = false
    
    @State private var isOtherListsPresented = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                if let movie = movie {
                    OffsetScrollView(offset: $offset, showIndicators: true, axis: .vertical) {
                        VStack {
                            BackgroundImageView(backdrop_path: movie.backdrop_path, offset: offset)
                            
                            HeaderView(movie: movie)
                            
                            let genres = movie.genres.map { $0.name }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(genres, id: \.self) { genre in
                                        Text(genre)
                                            .font(.subheadline.smallCaps())
                                            .bold()
                                            .foregroundColor(.cyan)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(RoundedRectangle(cornerRadius: 5).stroke(.cyan, lineWidth: 2))
                                            .clipShape(RoundedRectangle(cornerRadius: 5))
                                        
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, -32)
                            
                            Divider()
                            
                            HStack(spacing: 24) {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isListsSharePresented.toggle()
                                    }
                                }, label: {
                                    HStack {
                                        Image(systemName: "list.bullet")
                                            .font(.title)
                                            .foregroundColor(.white)
                                        
                                        Text("Liste e condivisione")
                                    }
                                })
                                .buttonStyle(.borderedProminent)
                            }
                            
                            if let providers = movie.watchProviders {
                                if let providersRegion = providers.results["IT"] {
                                    Divider()
                                    Text("Dove guardare")
                                        .fontWeight(.semibold)
                                        .font(.title3)
                                        .foregroundColor(.accentColor)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal)
                                    ScrollView(.horizontal) {
                                        HStack {
                                            ForEach(providersRegion.flatrate ?? [], id: \.self) { provider in
                                                providerView(provider: provider, type: "Abbonamento")
                                            }
                                            ForEach(providersRegion.buy ?? [], id: \.self) { provider in
                                                providerView(provider: provider, type: "Acquisto")
                                            }
                                            ForEach(providersRegion.rent ?? [], id: \.self) { provider in
                                                providerView(provider: provider, type: "Noleggio")
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            
                            Divider()
                            
                            Text("Descrizione")
                                .fontWeight(.semibold)
                                .font(.title3)
                                .foregroundColor(.accentColor)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            ExpandableText(movie.overview ?? "Non disponibile")
                                .font(.subheadline)
                                .lineLimit(4)
                                .moreButtonText("altro")
                                .padding(.horizontal)
                            
                            Divider()
                            
                            Text("Valutazioni")
                                .fontWeight(.semibold)
                                .font(.title3)
                                .foregroundColor(.accentColor)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            HistogramView(ratings: [])
                                .padding(.horizontal)
                            
                            HStack(spacing: 24) {
                                RatingBar(rating: $rating)
                                
                                Button {
                                    print("OK")
                                } label: {
                                    Text(NSLocalizedString("Valuta", comment: "Valuta"))
                                        .frame(height: 28)
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                
                            }
                            .padding()
                            
                            Divider()
                            
                            Text("Recensioni")
                                .fontWeight(.semibold)
                                .font(.title3)
                                .foregroundColor(.accentColor)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            ClearableTextField(hint: "Scrivi una recensione", text: $review, startIcon: "text.cursor", endIcon: "xmark.circle.fill", error: $reviewError, keyboardType: .default, textInputAutocapitalization: .sentences, autocorrectionDisabled: false, axis: .vertical)
                                .padding(.horizontal)
                            
                            HStack {
                                Button {
                                    print("OK")
                                } label: {
                                    Text(NSLocalizedString("Modifica", comment: "Modifica"))
                                        .frame(height: 28)
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .disabled(true)
                                
                                Button {
                                    print("OK")
                                } label: {
                                    Text(NSLocalizedString("Conferma", comment: "Conferma"))
                                        .frame(height: 28)
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(true)
                            }
                            .padding(.horizontal)
                            
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
                            
                            Divider()
                            
                            Text("Informazioni")
                                .fontWeight(.semibold)
                                .font(.title3)
                                .foregroundColor(.accentColor)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            Picker("Informazioni", selection: $selectedInfoTab) {
                                ForEach(InfoTabs.allCases, id: \.self) { tab in
                                    Text(tab.localized).tag(tab)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal)
                            
                            switch selectedInfoTab {
                            case .cast:
                                if let cast = movie.credits?.cast {
                                    ScrollView(.horizontal) {
                                        LazyHStack {
                                            ForEach(cast, id: \.self) { castMember in
                                                castView(castMember: castMember)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            case .crew:
                                if let crew = movie.credits?.crew.prefix(30) {
                                    ScrollView(.horizontal) {
                                        LazyHStack {
                                            ForEach(crew, id: \.self) { crewMember in
                                                crewView(crewMember: crewMember)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            case .details:
                                if let originalTitle = movie.original_title {
                                    Text(NSLocalizedString("Titolo originale e lingua originale", comment: "Titolo originale e lingua originale").uppercased())
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading)
                                        .padding(.top, 8)
                                        .padding(.bottom, 0)
                                    VStack(spacing: 0) {
                                        Text(originalTitle)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding()
                                        if let originalLanguageCode = movie.original_language {
                                            if let originalLanguage = Locale.current.localizedString(forLanguageCode: originalLanguageCode) {
                                                Divider()
                                                    .padding(.horizontal)
                                                Text(originalLanguage)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding()
                                            }
                                        }
                                    }
                                    .background(Color(UIColor.tertiarySystemFill)
                                        .cornerRadius(12))
                                    .padding(.horizontal)
                                }
                                
                                if let releaseDate = movie.release_date {
                                    Text(NSLocalizedString("Prima data di rilascio", comment: "Prima data di rilascio").uppercased())
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading)
                                        .padding(.top, 8)
                                        .padding(.bottom, 0)
                                    VStack(spacing: 0) {
                                        Text(Utils.formatDateToLocalString(dateString: releaseDate)!)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding()
                                    }
                                    .background(Color(UIColor.tertiarySystemFill)
                                        .cornerRadius(12))
                                    .padding(.horizontal)
                                }
                                
                                if let homepage = movie.homepage {
                                    Text("Homepage".uppercased())
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading)
                                        .padding(.top, 8)
                                        .padding(.bottom, 0)
                                    
                                    VStack(spacing: 0) {
                                        Button(action: {
                                            if let url = URL(string: homepage) {
                                                UIApplication.shared.open(url)
                                            } else {
                                                UIApplication.shared.open(URL(string: "https://themoviedb.org/movie/\(movie.id)")!)
                                            }
                                        }) {
                                            Text(NSLocalizedString("Vai alla homepage", comment: "Vai alla homepage"))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding()
                                        }
                                    }
                                    .background(Color(UIColor.tertiarySystemFill)
                                        .cornerRadius(12))
                                    .padding(.horizontal)
                                }
                                
                                
                                
                                if let collection = movie.belongs_to_collection {
                                    Text(NSLocalizedString("Collezione", comment: "Collezione").uppercased())
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading)
                                        .padding(.top, 8)
                                        .padding(.bottom, 0)
                                    HStack(spacing: 0) {
                                        if let collectionPosterPath = collection.poster_path {
                                            KFImage(URL(string: "https://image.tmdb.org/t/p/w185\(collectionPosterPath)"))
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 40, height: 40)
                                                .cornerRadius(10)
                                                .padding(.vertical, 4)
                                                .padding(.leading)
                                        }
                                        Text(collection.name)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding()
                                    }
                                    .background(Color(UIColor.tertiarySystemFill)
                                        .cornerRadius(12))
                                    .padding(.horizontal)
                                }
                                
                                if let budget = movie.budget, let revenue = movie.revenue, budget > 0 || revenue > 0 {
                                    Text(NSLocalizedString(budget > 0 && revenue > 0 ? "Budget e Incassi" : (budget < 0 ? "Incassi" : "Budget"), comment: "Budget e Incassi").uppercased())
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading)
                                        .padding(.top, 8)
                                        .padding(.bottom, 0)
                                    
                                    VStack(spacing: 0) {
                                        if budget > 0 {
                                            if let formattedBudget = Utils.formatToDollars(budget) {
                                                Text(revenue > 0 ? "Budget: \(formattedBudget)" : formattedBudget)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding()
                                            }
                                        }
                                        
                                        if revenue > 0 {
                                            if let formattedRevenue = Utils.formatToDollars(revenue) {
                                                if budget > 0 {
                                                    Divider()
                                                        .padding(.horizontal)
                                                }
                                                Text(budget > 0 ? "Incassi: \(formattedRevenue)" : formattedRevenue)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding()
                                            }
                                        }
                                    }
                                    .background(Color(UIColor.tertiarySystemFill)
                                        .cornerRadius(12))
                                    .padding(.horizontal)
                                }
                                
                                if let status = movie.status {
                                    Text(NSLocalizedString("Stato", comment: "Stato").uppercased())
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading)
                                        .padding(.top, 8)
                                        .padding(.bottom, 0)
                                    VStack(spacing: 0) {
                                        Text(NSLocalizedString(status, comment: status))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding()
                                    }
                                    .background(Color(UIColor.tertiarySystemFill)
                                        .cornerRadius(12))
                                    .padding(.horizontal)
                                }
                                
                                if let spokenLanguages = movie.spokenLanguages {
                                    Text(NSLocalizedString("Lingue parlate", comment: "Lingue parlate").uppercased())
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading)
                                        .padding(.top, 8)
                                        .padding(.bottom, 0)
                                    VStack(spacing: 0) {
                                        ForEach(spokenLanguages.indices, id: \.self) { index in
                                            if index > 0 {
                                                Divider()
                                                    .padding(.horizontal)
                                            }
                                            Text(Locale.current.localizedString(forLanguageCode: spokenLanguages[index].iso_639_1)!)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding()
                                            
                                        }
                                    }
                                    .background(Color(UIColor.tertiarySystemFill)
                                        .cornerRadius(12))
                                    .padding(.horizontal)
                                }
                                
                                if let productionCompanies = movie.productionCompanies {
                                    Text(NSLocalizedString("Case produttrici", comment: "Case produttrici").uppercased())
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading)
                                        .padding(.top, 8)
                                        .padding(.bottom, 0)
                                    VStack(spacing: 0) {
                                        ForEach(productionCompanies.indices, id: \.self) { index in
                                            if index > 0 {
                                                Divider()
                                                    .padding(.horizontal)
                                            }
                                            HStack(spacing: 0) {
                                                if let logoPath = productionCompanies[index].logo_path {
                                                    KFImage(URL(string: "https://image.tmdb.org/t/p/w92\(logoPath)"))
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 40, height: 40)
                                                        .cornerRadius(10)
                                                        .padding(.vertical, 4)
                                                        .padding(.leading)
                                                }
                                                Text(productionCompanies[index].name)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding()
                                            }
                                        }
                                    }
                                    .background(Color(UIColor.tertiarySystemFill)
                                        .cornerRadius(12))
                                    .padding(.horizontal)
                                }
                                
                                if let productionCountries = movie.productionCountries {
                                    Text(NSLocalizedString("Paesi di produzione", comment: "Paesi di produzione").uppercased())
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading)
                                        .padding(.top, 8)
                                        .padding(.bottom, 0)
                                    VStack(spacing: 0) {
                                        ForEach(productionCountries.indices, id: \.self) { index in
                                            if index > 0 {
                                                Divider()
                                                    .padding(.horizontal)
                                            }
                                            
                                            Text(Locale.current.localizedString(forRegionCode: productionCountries[index].iso_3166_1)!)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding()
                                        }
                                    }
                                    .background(Color(UIColor.tertiarySystemFill)
                                        .cornerRadius(12))
                                    .padding(.horizontal)
                                }
                            case .videos:
                                if let videos = movie.videos?.results {
                                    let officialVideos = videos.filter { $0.official }
                                    
                                    if !officialVideos.isEmpty && !videos.isEmpty {
                                        let sortedVideos = officialVideos.sorted {
                                            if $0.type == "Trailer" { return true }
                                            if $1.type == "Trailer" { return false }
                                            if $0.type == "Teaser" && $1.type != "Trailer" { return true }
                                            return false
                                        }
                                        
                                        Text(NSLocalizedString("Video disponibili", comment: "Video disponibili").uppercased())
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading)
                                            .padding(.top, 8)
                                            .padding(.bottom, 0)
                                        
                                        VStack(spacing: 0) {
                                            ForEach(sortedVideos.indices, id: \.self) { index in
                                                if index > 0 {
                                                    Divider()
                                                        .padding(.horizontal)
                                                }
                                                
                                                let video = sortedVideos[index]
                                                let language = Locale.current.localizedString(forLanguageCode: video.iso_639_1) ?? ""
                                                let country = Locale.current.localizedString(forRegionCode: video.iso_3166_1) ?? ""
                                                
                                                Button(action: {
                                                    openVideo(video)
                                                }) {
                                                    VStack(alignment: .leading) {
                                                        Text(video.name)
                                                            .bold()
                                                            .lineLimit(1)
                                                        Text("\(language) (\(country))")
                                                            .font(.subheadline)
                                                            .foregroundColor(.secondary)
                                                    }
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding()
                                                }
                                            }
                                        }
                                        .background(Color(UIColor.tertiarySystemFill)
                                            .cornerRadius(12))
                                        .padding(.horizontal)
                                    } else {
                                        VStack(spacing: 0) {
                                            Text(NSLocalizedString("Nessun video disponibile", comment: "Nessun video disponibile"))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding()
                                        }
                                        .background(Color(UIColor.tertiarySystemFill)
                                            .cornerRadius(12))
                                        .padding(.horizontal)
                                    }
                                } else {
                                    VStack(spacing: 0) {
                                        Text(NSLocalizedString("Nessun video disponibile", comment: "Nessun video disponibile"))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding()
                                    }
                                    .background(Color(UIColor.tertiarySystemFill)
                                        .cornerRadius(12))
                                    .padding(.horizontal)
                                }
                                
                            }
                            
                            Divider()
                            
                            Text("Film simili")
                                .fontWeight(.semibold)
                                .font(.title3)
                                .foregroundColor(.accentColor)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            Spacer()
                        }
                    }
                    .ignoresSafeArea()
                    .overlay(
                        NavigationBar(title: movie.title, offset: $offset) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                    .blur(radius: isListsSharePresented ? 10 : 0)
                    if isListsSharePresented {
                        VStack(spacing: 0) {
                            if !isOtherListsPresented {
                                Button(action: { isInWatched.toggle() }) {
                                    HStack {
                                        Image(systemName: isInWatched ? "eye.fill" : "eye")
                                            .foregroundStyle(Color.primary)
                                            .frame(width: 28)
                                        Text("Film visti")
                                            .foregroundStyle(Color.primary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Spacer()
                                        Image(systemName: isInWatched ? "checkmark.circle.fill" : "checkmark.circle")
                                            .foregroundStyle(isInWatched ? Color.mint : Color.primary)
                                            .frame(width: 28)
                                    }
                                    .padding()
                                }
                                
                                Divider()
                                
                                Button(action: { isInWatchlist.toggle() }) {
                                    HStack {
                                        Image(systemName: isInWatchlist ? "bookmark.fill" : "bookmark")
                                            .foregroundStyle(Color.primary)
                                            .frame(width: 28)
                                        Text("Watchlist")
                                            .foregroundStyle(Color.primary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Spacer()
                                        Image(systemName: isInWatchlist ? "checkmark.circle.fill" : "checkmark.circle")
                                            .foregroundStyle(isInWatchlist ? Color.mint : Color.primary)
                                            .frame(width: 28)
                                    }
                                    .padding()
                                }
                                
                                Divider()
                                
                                Button(action: { isInFavorites.toggle() }) {
                                    HStack {
                                        Image(systemName: isInFavorites ? "heart.fill" : "heart")
                                            .foregroundStyle(Color.primary)
                                            .frame(width: 28)
                                        Text("Preferiti")
                                            .foregroundStyle(Color.primary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Spacer()
                                        Image(systemName: isInFavorites ? "checkmark.circle.fill" : "checkmark.circle")
                                            .foregroundStyle(isInFavorites ? Color.mint : Color.primary)
                                            .frame(width: 28)
                                    }
                                    .padding()
                                }
                                
                                Divider()
                                
                                HStack {
                                    Image(systemName: "list.bullet")
                                        .frame(width: 28)
                                    Text("Altre liste")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .frame(width: 28)
                                }
                                .padding()
                                
                                Divider()
                                
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                        .frame(width: 28)
                                    Text("Condividi")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Image(systemName: "chevron.right")
                                        .frame(width: 28)
                                }
                                .padding()
                                
                            }
                            
                            Utils.linearGradient
                                .frame(width: .infinity, height: 1)
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isListsSharePresented = false
                                }
                            }) {
                                Text("Annulla")
                                    .foregroundStyle(Color.primary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding()
                            }
                        }
                        .background(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Utils.linearGradient)
                        )
                        .cornerRadius(12)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .padding()
                        .transition(.move(edge: .bottom))
                    }
                } else {
                    ProgressView("Caricamento in corso...")
                        .progressViewStyle(.circular)
                        .tint(.accentColor)
                        .controlSize(.large)
                }
            }
            .onAppear {
                getMovieDetails()
            }
        }
        
        .navigationBarBackButtonHidden(true)
        .padding(.bottom, 1)
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
    
    func openVideo(_ video: Video) {
        let urlString: String
        switch video.site {
        case "YouTube":
            urlString = "https://www.youtube.com/watch?v=\(video.key)"
        case "Vimeo":
            urlString = "https://vimeo.com/\(video.key)"
        default:
            return
        }
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func providerView(provider: Provider, type: String) -> some View {
        HStack {
            KFImage(URL(string: "https://image.tmdb.org/t/p/w154\(provider.logo_path)"))
                .resizable()
                .frame(width: 70, height: 70)
                .cornerRadius(12)
                .padding(.leading, 4)
                .padding(.vertical, 4)
            VStack(alignment: .leading) {
                Text(provider.provider_name)
                    .bold()
                Text(type)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding(.trailing, 8)
        }
        .background(RoundedRectangle(cornerRadius: 12).stroke(.secondary, lineWidth: 2))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    func castView(castMember: Cast) -> some View {
        NavigationLink(destination: PersonDetailsView(personId: castMember.id)) {
            VStack(spacing: 0) {
                if let profilePath = castMember.profile_path {
                    KFImage(URL(string: "https://image.tmdb.org/t/p/w185\(profilePath)"))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .cornerRadius(12)
                        .padding(.horizontal, 4)
                        .padding(.top, 4)
                } else {
                    Image("error_404")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .cornerRadius(12)
                        .padding(.horizontal, 4)
                        .padding(.top, 4)
                }
                Text(castMember.name)
                    .font(.subheadline)
                    .lineLimit(2)
                    .fontWeight(.semibold)
                    .foregroundColor(.accentColor)
                    .frame(maxWidth: 100, alignment: .leading)
                    .padding(.horizontal, 4)
                    .padding(.top, 4)
                Text(castMember.character)
                    .font(.caption)
                    .lineLimit(1)
                    .frame(maxWidth: 100, alignment: .leading)
                    .padding(.horizontal, 4)
                    .padding(.top, 4)
                Spacer()
            }
            .frame(height: 174)
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
    
    func crewView(crewMember: Crew) -> some View {
        NavigationLink(destination: PersonDetailsView(personId: crewMember.id)) {
            VStack(spacing: 0) {
                if let profilePath = crewMember.profile_path {
                    KFImage(URL(string: "https://image.tmdb.org/t/p/w185\(profilePath)"))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .cornerRadius(12)
                        .padding(.horizontal, 4)
                        .padding(.top, 4)
                } else {
                    Image("error_404")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .cornerRadius(12)
                        .padding(.horizontal, 4)
                        .padding(.top, 4)
                }
                Text(crewMember.name)
                    .font(.subheadline)
                    .lineLimit(2)
                    .fontWeight(.semibold)
                    .foregroundColor(.accentColor)
                    .frame(maxWidth: 100, alignment: .leading)
                    .padding(.horizontal, 4)
                    .padding(.top, 4)
                Text(crewMember.job)
                    .font(.caption)
                    .lineLimit(1)
                    .frame(maxWidth: 100, alignment: .leading)
                    .padding(.horizontal, 4)
                    .padding(.top, 4)
                Spacer()
            }
            .frame(height: 174)
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
    
}

#Preview {
    MovieDetailsView(movieId: 299536) // 872585, 299564, 299536
        .accentColor(.cyan)
}

struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

struct OffsetScrollView<Content: View>: View {
    var content: Content
    @Binding var offset: CGFloat
    var showIndicators: Bool
    var axis: Axis.Set
    
    init(offset: Binding<CGFloat>, showIndicators: Bool, axis: Axis.Set, @ViewBuilder content: () -> Content) {
        self.content = content()
        self._offset = offset
        self.showIndicators = showIndicators
        self.axis = axis
    }
    
    var body: some View {
        ScrollView(axis, showsIndicators: showIndicators, content: {
            content
                .background(GeometryReader {
                    Color.clear.preference(key: OffsetKey.self,
                                           value: -$0.frame(in: .named("scroll")).origin.y)
                })
        })
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(OffsetKey.self) { offset = $0 }
    }
}

struct RatingBar: View {
    @Binding var rating: CGFloat
    
    var body: some View {
        AxisRatingBar(value: $rating) {
            ARStar(count: 5, innerRatio: 0.9)
                .fill(.gray.opacity(0.2))
        } foreground: {
            ARStar(count: 5, innerRatio: 0.9)
                .fill(Color.accentColor)
        }
    }
}

struct BackgroundImageView: View {
    let backdrop_path: String?
    let offset: CGFloat
    
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                if let backdropPath = backdrop_path {
                    KFImage(URL(string: backdropPath.first == "/" ? "https://image.tmdb.org/t/p/w1280\(backdropPath)" : backdropPath))
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width,
                               height: max(proxy.size.height - offset, UIScreen.main.bounds.width * 9 / 16))
                        .clipped()
                        .offset(y: min(offset, 0))
                } else {
                    Image("error_404")
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width,
                               height: max(proxy.size.height - offset, UIScreen.main.bounds.width * 9 / 16))
                        .clipped()
                        .offset(y: min(offset, 0))
                }
                
                LinearGradient(gradient: Gradient(colors: [Color(uiColor: UIColor.systemBackground).opacity(0.0), Color(uiColor: UIColor.systemBackground).opacity(0.0), Color(uiColor: UIColor.systemBackground).opacity(0.0), Color(uiColor: UIColor.systemBackground).opacity(1.0)]), startPoint: .top, endPoint: .bottom)
                    .frame(width: UIScreen.main.bounds.width,
                           height: max(proxy.size.height + offset, UIScreen.main.bounds.width * 9 / 16))
                    .offset(y: min(-offset, 0))
            }
            .frame(height: UIScreen.main.bounds.width * 9 / 16)
        }
    }
}

struct HeaderView: View {
    let movie: Movie?
    
    var body: some View {
        HStack(alignment: .top) {
            if let posterPath = movie?.poster_path {
                KFImage(URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)"))
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width / 3, height: (UIScreen.main.bounds.width / 3) * 1.5)
                    .cornerRadius(10)
                    .shadow(color: .primary.opacity(0.2) , radius: 5)
                    .offset(y: -40)
            } else {
                Image("error_404")
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width / 3, height: (UIScreen.main.bounds.width / 3) * 1.5)
                    .cornerRadius(10)
                    .shadow(color: .primary.opacity(0.2) , radius: 5)
                    .offset(y: -40)
            }
            
            VStack(spacing: 8) {
                Text(movie?.title ?? "Non disponibile")
                    .bold()
                    .font(.title2)
                    .foregroundColor(.accentColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if let tagline = movie?.tagline {
                    if !tagline.isEmpty {
                        Text("\"\(tagline)\"")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .italic()
                    }
                }
                
                HStack {
                    if let releaseDate = movie?.release_date {
                        Text("\(releaseDate.prefix(4))" + " | Diretto da:")
                            .font(.footnote)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(1)
                    }
                    Spacer()
                    if let runtime = movie?.runtime {
                        Text("\(runtime) min")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                
                //                            if let releaseDate = movie?.release_date {
                //                                let formattedDate = Utils.convertDate(from: releaseDate)
                //                                Text(formattedDate ?? "")
                //                                    .font(.footnote)
                //                                    .frame(maxWidth: .infinity, alignment: .leading)
                //                            }
                
                let directors = movie?.credits?.crew.filter { $0.job == "Director" }.map { $0.name } ?? ["Non disponibile"]
                let directorsString = directors.joined(separator: ", ")
                
                Text(directorsString)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal)
    }
}

extension UINavigationController: UIGestureRecognizerDelegate {
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
