//
//  TVShowDetailsView.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 28/08/23.
//

import SwiftUI
import Alamofire
import Kingfisher
import ExpandableText
import AxisRatingBar
import ACarousel
import CarouselStack

enum TVShowTabSelection {
    case info
    case episodes
}

struct TVShowDetailsView: View {
    let showId: Int64
    @State private var show: TVShow?
    
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
    
    @State private var isInWatching = false
    
    @State private var isInWatchlist = false
    
    @State private var isInFavorites = false
    
    @State private var isListsSharePresented = false
    
    @State private var isOtherListsPresented = false
    
    @State private var selectedTVShowTab = TVShowTabSelection.info
    
    @State private var episodes: [Episode] = []
    
    @State private var isSeasonDetailsPresented: [Int: Bool] = [:]
    
    @State private var isEpisodeWatched: [Int: [Int: Bool]] = [:]
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                if let show = show {
                    OffsetScrollView(offset: $offset, showIndicators: true, axis: .vertical) {
                        VStack {
                            BackgroundImageView(backdrop_path: show.backdropPath, offset: offset)
                            
                            ShowHeaderView(show: show)
                            
                            let genres = show.genres.map { $0.name }
                            
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
                            
                            Divider()
                            
                            VStack {
                                HStack {
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedTVShowTab = .info
                                        }
                                    } ) {
                                        VStack {
                                            Text("Informazioni")
                                                .fontWeight(selectedTVShowTab == .info ? .semibold : .regular)
                                                .font(.title3.smallCaps())
                                                .foregroundStyle(Color.primary)
                                                .frame(width: UIScreen.main.bounds.width / 2, height: 44)
                                        }
                                    }
                                    
                                    Divider().frame(height: 44)
                                    
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedTVShowTab = .episodes
                                        }
                                    } ) {
                                        VStack {
                                            Text("Episodi")
                                                .fontWeight(selectedTVShowTab == .episodes ? .semibold : .regular)
                                                .font(.title3.smallCaps())
                                                .foregroundStyle(Color.primary)
                                                .frame(width: UIScreen.main.bounds.width / 2, height: 44)
                                        }
                                    }
                                }
                                UnevenRoundedRectangle(topLeadingRadius: selectedTVShowTab == .info ? 0 : 6, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: selectedTVShowTab == .info ? 6 : 0, style: .continuous)
                                    .fill(Color.accentColor)
                                    .frame(width: UIScreen.main.bounds.width / 2, height: 7)
                                    .offset(x: (UIScreen.main.bounds.width / 4) * (selectedTVShowTab == .info ? -1 : 1))
                            }.frame(width: UIScreen.main.bounds.width, height: 44)
                            
                            switch selectedTVShowTab {
                            case .info:
                                VStack {
                                    if let providers = show.watchProviders {
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
                                    
                                    if let overview = show.overview {
                                        ExpandableText(overview.isEmpty ? "Non disponibiile" : overview)
                                            .font(.subheadline)
                                            .lineLimit(4)
                                            .moreButtonText("altro")
                                            .padding(.horizontal)
                                    }
                                    
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
                                        if let cast = show.credits?.cast {
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
                                        if let crew = show.credits?.crew.prefix(30) {
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
                                        if show.originalName != "" {
                                            Text(NSLocalizedString("Titolo originale e lingua originale", comment: "Titolo originale e lingua originale").uppercased())
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.leading)
                                                .padding(.top, 8)
                                                .padding(.bottom, 0)
                                            VStack(spacing: 0) {
                                                Text(show.originalName)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding()
                                                if let originalLanguageCode = show.originalLanguage {
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
                                        
                                        if let releaseDate = show.firstAirDate {
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
                                        
                                        if let homepage = show.homepage {
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
                                                        UIApplication.shared.open(URL(string: "https://themoviedb.org/tv/\(show.id)")!)
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
                                        
                                        
                                        if let status = show.status {
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
                                        
                                        if let spokenLanguages = show.languages {
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
                                                    Text(Locale.current.localizedString(forLanguageCode: spokenLanguages[index])!)
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                        .padding()
                                                    
                                                }
                                            }
                                            .background(Color(UIColor.tertiarySystemFill)
                                                .cornerRadius(12))
                                            .padding(.horizontal)
                                        }
                                        
                                        if let productionCompanies = show.productionCompanies {
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
                                        
                                        if let productionCountries = show.productionCountries {
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
                                        if let videos = show.videos?.results {
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
                                    
                                }.transition(.move(edge: .leading))
                            case .episodes:
                                VStack {
                                    Divider()
                                    Text("Inizia il monitoraggio")
                                        .fontWeight(.semibold)
                                        .font(.title3)
                                        .foregroundColor(.accentColor)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal)
                                    
                                    CarouselStack(episodes) { episode in
                                        HStack(alignment: .center) {
                                            if let imagePath = episode.imagePath {
                                                KFImage(URL(string: "https://image.tmdb.org/t/p/w185\(imagePath)"))
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 80, height: 80)
                                                    .cornerRadius(10)
                                                    .padding(5)
                                            } else {
                                                Image("error_404")
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 80, height: 80)
                                                    .cornerRadius(10)
                                                    .padding(5)
                                            }
                                            VStack {
                                                HStack(spacing: 0) {
                                                    if let seasonNumber = episode.seasonNumber {
                                                        Text("S\(Utils.convertSeasonEpisodeNumber(seasonNumber)) | ")
                                                            .fontWeight(.semibold)
                                                    }
                                                    Text("E\(Utils.convertSeasonEpisodeNumber(episode.episodeNumber))")
                                                        .fontWeight(.semibold)
                                                }
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                Text(episode.name ?? "Episodio \(episode.episodeNumber)")
                                                    .font(.callout)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                            .padding(.leading, -5)
                                            .padding(.trailing, 5)
                                            Spacer()
                                            Button(action: {}) {
                                                ZStack {
                                                    Circle()
                                                        .fill(Color(uiColor: .systemGray4))
                                                        .frame(width: 40, height: 40)
                                                    
                                                    Image(systemName: "checkmark")
                                                        .foregroundStyle(Color.gray)
                                                        .fontWeight(.medium)
                                                        .font(.title3)
                                                }
                                            }.padding(.trailing, 10)
                                        }
                                        .frame(height: 90)
                                        .background(.ultraThickMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .strokeBorder(Utils.linearGradient)
                                        )
                                        .cornerRadius(12)
                                        .shadow(color: Color.primary.opacity(0.4) , radius: 3)
                                    }.frame(height: 100)
                                    
                                    Divider()
                                    
                                    Text("Tutti gli episodi")
                                        .fontWeight(.semibold)
                                        .font(.title3)
                                        .foregroundColor(.accentColor)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal)
                                    
                                    if let seasons = show.seasons {
                                        ForEach(seasons, id: \.self) { season in
                                            if season.seasonNumber != 0 {
                                                SeasonView(season: season, isSeasonDetailsPresented: $isSeasonDetailsPresented, isEpisodeWatched: $isEpisodeWatched, linearGradient: Utils.linearGradient)
                                            }
                                        }
                                        if let specialSeason = seasons.first(where: { $0.seasonNumber == 0 }) {
                                            SeasonView(season: specialSeason, isSeasonDetailsPresented: $isSeasonDetailsPresented, isEpisodeWatched: $isEpisodeWatched, linearGradient: Utils.linearGradient)
                                        }
                                    }
                                    
                                }.transition(.move(edge: .trailing))
                            }
                        }
                    }
                    .ignoresSafeArea()
                    .overlay(
                        NavigationBar(title: show.name, offset: $offset) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                    .blur(radius: isListsSharePresented ? 10 : 0)
                    if isListsSharePresented {
                        VStack(spacing: 0) {
                            if !isOtherListsPresented {
                                Button(action: { isInWatching.toggle() }) {
                                    HStack {
                                        Image(systemName: isInWatching ? "eye.fill" : "eye")
                                            .foregroundStyle(Color.primary)
                                            .frame(width: 28)
                                        Text("Serie TV in visione")
                                            .foregroundStyle(Color.primary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Spacer()
                                        Image(systemName: isInWatching ? "checkmark.circle.fill" : "checkmark.circle")
                                            .foregroundStyle(isInWatching ? Color.mint : Color.primary)
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
                Task {
                    do {
                        var show = try await getTVShowDetails()
                        
                        for (index, season) in show.seasons!.enumerated() {
                            do {
                                let detailedSeason = try await getSeasonDetails(seasonNumber: Int32(season.seasonNumber))
                                isSeasonDetailsPresented[season.seasonNumber] = false
                                if season.seasonNumber != 0 {
                                    self.episodes.append(contentsOf: detailedSeason.episodes ?? [])
                                }
                                show.seasons?[index] = detailedSeason
                            } catch {
                                print("Error fetching details for season \(season.seasonNumber): \(error)")
                            }
                        }
                        
                        self.show = show
                        
                    } catch {
                        print("Error fetching show details: \(error)")
                    }
                }
            }
        }
            .navigationBarBackButtonHidden(true)
            .padding(.bottom, 1)
    }
    
    func getTVShowDetails() async throws -> TVShow {
        return try await withCheckedThrowingContinuation { continuation in
            APIManager.getTVShowDetails(showId: showId) { (result: AFResult<TVShow>) in
                switch result {
                case .success(let show):
                    continuation.resume(returning: show)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    
    func getSeasonDetails(seasonNumber: Int32) async throws -> Season {
        return try await withCheckedThrowingContinuation { continuation in
            APIManager.getSeasonDetails(showId: showId, seasonNumber: seasonNumber) { (result: AFResult<Season>) in
                switch result {
                case .success(let season):
                    continuation.resume(returning: season)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
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
    TVShowDetailsView(showId: 1396) // 872585, 299564, 299536
        .accentColor(.cyan)
}

struct ShowHeaderView: View {
    let show: TVShow?
    
    var body: some View {
        HStack(alignment: .top) {
            if let posterPath = show?.posterPath {
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
                Text(show?.name ?? "Non disponibile")
                    .bold()
                    .font(.title2)
                    .foregroundColor(.accentColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if let tagline = show?.tagline {
                    if !tagline.isEmpty {
                        Text("\"\(tagline)\"")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .italic()
                    }
                }
                
                HStack {
                    if let releaseDate = show?.firstAirDate {
                        Text("\(releaseDate.prefix(4))" + " | Creata da:")
                            .font(.footnote)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(1)
                    }
                    Spacer()
                    if let numberOfEpisodes = show?.numberOfEpisodes {
                        Text("\(numberOfEpisodes) episodi")
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
                
                if let createdBy = show?.createdBy, !createdBy.isEmpty {
                    let creatorsString = show?.createdBy?.map { creator in
                        creator.name
                    }.joined(separator: ", ")
                    Text(creatorsString ?? "Non disponibiile")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                } else {
                    let directors = show?.credits?.crew.filter { $0.job == "Director" }.map { $0.name } ?? ["Non disponibile"]
                    let directorsString = directors.joined(separator: ", ")
                    
                    Text(directorsString)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct SeasonView: View {
    var season: Season
    @Binding var isSeasonDetailsPresented: [Int: Bool]
    @Binding var isEpisodeWatched: [Int: [Int: Bool]]
    var linearGradient: LinearGradient
    
    var body: some View {
        Button(action: { withAnimation(.easeInOut(duration: 0.2)) { isSeasonDetailsPresented[season.seasonNumber]?.toggle() } }) {
            HStack {
                if let posterPath = season.posterPath {
                    KFImage(URL(string: "https://image.tmdb.org/t/p/w185\(posterPath)"))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .cornerRadius(10)
                        .padding(5)
                } else {
                    Image("error_404")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .cornerRadius(10)
                        .padding(5)
                }
                VStack {
                    HStack {
                        Text(season.name ?? "Stagione \(season.seasonNumber)")
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.primary)
                            .frame(alignment: .leading)
                        
                        Image(systemName: "arrow.up.forward.app")
                            .foregroundStyle(Color.accentColor)
                        
                        Spacer()
                    }.padding(.top, 0)
                }
                
                Spacer()
                
                Text("0/\(season.episodes?.count ?? 0)")
                    .foregroundStyle(Color.primary)
                
                Button(action: {}) {
                    ZStack {
                        Circle()
                            .fill(Color(uiColor: .systemGray4))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "checkmark")
                            .foregroundStyle(Color.gray)
                            .fontWeight(.medium)
                            .font(.title3)
                    }
                }.padding(.trailing, 10)
            }
            .frame(height: 90)
            .background(.ultraThickMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(linearGradient)
            )
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .sheet(isPresented: Binding<Bool>(
            get: { self.isSeasonDetailsPresented[season.seasonNumber] ?? false },
            set: { newValue in self.isSeasonDetailsPresented[season.seasonNumber] = newValue }
        ))
        {
            SeasonDetailsView(season: season, isEpisodeWatched: $isEpisodeWatched, linearGradient: linearGradient)
        }
    }
}

struct SeasonDetailsView: View {
    var season: Season
    @Binding var isEpisodeWatched: [Int: [Int: Bool]]
    var linearGradient: LinearGradient
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                LazyVStack {
                    Button(action: { dismiss() }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .foregroundStyle(Color.accentColor)
                            Text("Indietro")
                                .foregroundStyle(Color.accentColor)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    }
                    HStack {
                        VStack {
                            if let posterPath = season.posterPath {
                                KFImage(URL(string: "https://image.tmdb.org/t/p/w342\(posterPath)"))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 180)
                                    .cornerRadius(10)
                                    .padding(5)
                            } else {
                                Image("error_404")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 180)
                                    .cornerRadius(10)
                                    .padding(5)
                            }
                            Spacer()
                        }
                        VStack {
                            if let overview = season.overview, !overview.isEmpty {
                                Text("Descrizione")
                                    .fontWeight(.semibold)
                                    .font(.headline)
                                    .foregroundStyle(Color.accentColor)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text(overview)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.subheadline)
                                
                            }
                            
                                Text("Informazioni")
                                    .fontWeight(.semibold)
                                    .font(.headline)
                                    .foregroundStyle(Color.accentColor)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            
                            let seasonWatchedEpisodes = isEpisodeWatched[season.seasonNumber]?.filter { $0.value == true }.count ?? 0
                            let seasonTotalEpisodes = season.episodes?.count ?? 0
                            Text("\(seasonWatchedEpisodes) \(seasonWatchedEpisodes == 1 ? "episodio" : "episodi") visti su \(seasonTotalEpisodes) \(seasonTotalEpisodes == 1 ? "episodio" : "episodi") totali")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.subheadline)
                            
                            if let airDate = season.airDate {
                                Text("Rilasciata il \(Utils.formatDateToLocalString(dateString: airDate) ?? "Non disponibile")")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.subheadline)
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    Text("Tutti gli episodi")
                        .fontWeight(.semibold)
                        .font(.title3)
                        .foregroundColor(.accentColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    ForEach(season.episodes ?? [], id: \.self) { episode in
                        HStack(alignment: .center) {
                            if let imagePath = episode.imagePath {
                                KFImage(URL(string: "https://image.tmdb.org/t/p/w185\(imagePath)"))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(10)
                                    .padding(5)
                            } else {
                                Image("error_404")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(10)
                                    .padding(5)
                            }
                            VStack {
                                HStack(spacing: 0) {
                                    if let seasonNumber = episode.seasonNumber {
                                        Text("S\(Utils.convertSeasonEpisodeNumber(seasonNumber)) | ")
                                            .fontWeight(.semibold)
                                    }
                                    Text("E\(Utils.convertSeasonEpisodeNumber(episode.episodeNumber))")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                Text(episode.name ?? "Episodio \(episode.episodeNumber)")
                                    .font(.callout)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.leading, -5)
                            .padding(.trailing, 5)
                            Spacer()
                            Button(action: {}) {
                                ZStack {
                                    Circle()
                                        .fill(Color(uiColor: .systemGray4))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color.gray)
                                        .fontWeight(.medium)
                                        .font(.title3)
                                }
                            }.padding(.trailing, 10)
                        }
                        .frame(height: 90)
                        .background(.ultraThickMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(linearGradient)
                        )
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle(season.name ?? "Stagione \(season.seasonNumber)")
        }
        .accentColor(.cyan)
    }
}
