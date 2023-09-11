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

enum TVShowTabSelection {
    case info
    case episodes
}

private enum FocusField: Int, CaseIterable {
    case review
}

struct TVShowDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authManager: AuthManager
    @ObservedObject var viewModel: TVShowDetailsViewModel
    
    @State var offset: CGFloat = 0
    @State private var showReviews = false
    @State private var review = ""
    @State private var reviewError = false
    @State private var selectedInfoTab = InfoTabs.cast
    @State private var showNavigationBar: Bool = false
    @State private var observation: NSKeyValueObservation?
    @State private var isListsSharePresented = false
    @State private var isOtherListsPresented = false
    @State private var isEditingReview: Bool = false
    
    @FocusState private var focusedReview: FocusField?
    
    init(showId: Int64, currentUserUid: String) {
        self.viewModel = TVShowDetailsViewModel(showId: showId, currentUserUid: currentUserUid)
    }
    
    @State private var selectedTVShowTab = TVShowTabSelection.info
    
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                if let show = viewModel.show {
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
                                    if !isListsSharePresented {
                                        Task {
                                            await viewModel.loadUserRawLists()
                                        }
                                    }
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
                                            Text("Stagioni")
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
                                    
                                    HistogramView(ratings: $viewModel.allRatings)
                                        .padding(.horizontal)
                                    
                                    HStack(spacing: 24) {
                                        RatingBar(rating: $viewModel.currentUserRating)
                                        
                                        Button {
                                            Task {
                                                await viewModel.addOrUpdateRating(value: viewModel.currentUserRating * 5)
                                            }
                                        } label: {
                                            Text(NSLocalizedString("Valuta", comment: "Valuta"))
                                                .frame(height: 28)
                                                .frame(maxWidth: .infinity)
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .disabled(viewModel.currentUserRating == viewModel.oldRating || viewModel.currentUserRating == 0.0)
                                    }
                                    .padding()
                                    
                                    Divider()
                                    
                                    Text("Recensioni")
                                        .fontWeight(.semibold)
                                        .font(.title3)
                                        .foregroundColor(.accentColor)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal)
                                    
                                    ClearableTextField(hint: "Scrivi una recensione", text: $viewModel.reviewText, startIcon: "text.cursor", endIcon: "xmark.circle.fill", error: $reviewError, keyboardType: .default, textInputAutocapitalization: .sentences, autocorrectionDisabled: false, axis: .vertical)
                                        .padding(.horizontal)
                                        .focused($focusedReview, equals: .review)
                                        .toolbar {
                                            ToolbarItem(placement: .keyboard) {
                                                Button("Fatto") {
                                                    focusedReview = nil
                                                }
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                        }
                                        .disabled(viewModel.currentUserReview != nil && !isEditingReview)
                                    
                                    if let currentUserReview = viewModel.currentUserReview {
                                        Text("Ultima modifica: \(Utils.formatDateToLocalString(date: currentUserReview.timestamp.dateValue()))")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .lineLimit(1)
                                            .font(.caption)
                                            .foregroundStyle(Color.secondary)
                                            .padding(.vertical, 0)
                                            .padding(.horizontal)
                                    }
                                    
                                    HStack {
                                        Button {
                                            isEditingReview.toggle()
                                        } label: {
                                            Text(NSLocalizedString("Modifica", comment: "Modifica"))
                                                .frame(height: 28)
                                                .frame(maxWidth: .infinity)
                                        }
                                        .buttonStyle(.bordered)
                                        .disabled(viewModel.currentUserReview == nil || isEditingReview)
                                        
                                        Button {
                                            Task {
                                                await viewModel.addOrUpdateReview(reviewText: viewModel.reviewText)
                                                isEditingReview = false
                                            }
                                        } label: {
                                            Text(NSLocalizedString("Conferma", comment: "Conferma"))
                                                .frame(height: 28)
                                                .frame(maxWidth: .infinity)
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .disabled(
                                            viewModel.reviewText.count <= 3 ||
                                            viewModel.reviewText == viewModel.oldReviewText ||
                                            (viewModel.currentUserReview != nil && !isEditingReview)
                                        )
                                    }
                                    .padding(.horizontal)
                                    
                                    if viewModel.reviewsCount != 0 {
                                        Button {
                                            Task {
                                                await viewModel.fetchAllReviews()
                                                showReviews.toggle()
                                            }
                                        } label: {
                                            Text("Visualizza tutte le recensioni (\(viewModel.reviewsCount))")
                                                .frame(height: 28)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.horizontal)
                                        }
                                        .sheet(isPresented: $showReviews) {
                                            if !viewModel.allReviews.isEmpty {
                                                List {
                                                    ForEach(viewModel.allReviews, id: \.user.uid) { review in
                                                        HStack(alignment: .top) {
                                                            KFImage(URL(string: review.user.profilePath))
                                                                .resizable()
                                                                .clipShape(Circle())
                                                                .scaledToFill()
                                                                .frame(width: 50, height: 50)
                                                                .cornerRadius(8)
                                                                .padding(.leading, -8)
                                                            VStack {
                                                                Text("**\(review.user.username)** | Data recensione: \(Utils.formatDateToLocalString(date: review.timestamp.dateValue()))")
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
                                            } else {
                                                ProgressView("Caricamento in corso...")
                                                    .progressViewStyle(.circular)
                                                    .tint(.accentColor)
                                                    .controlSize(.large)
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
                                        if let cast = show.credits?.cast, !cast.isEmpty {
                                            ScrollView(.horizontal) {
                                                LazyHStack {
                                                    ForEach(cast, id: \.self) { castMember in
                                                        castView(castMember: castMember)
                                                    }
                                                }
                                                .padding(.horizontal)
                                            }
                                        } else {
                                            VStack(spacing: 0) {
                                                Text("Non disponibile")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding()
                                            }
                                            .background(Color(UIColor.tertiarySystemFill)
                                                .cornerRadius(12))
                                            .padding(.horizontal)
                                        }
                                    case .crew:
                                        if let crew = show.credits?.crew.prefix(30), !crew.isEmpty {
                                            ScrollView(.horizontal) {
                                                LazyHStack {
                                                    ForEach(crew, id: \.self) { crewMember in
                                                        crewView(crewMember: crewMember)
                                                    }
                                                }
                                                .padding(.horizontal)
                                            }
                                        } else {
                                            VStack(spacing: 0) {
                                                Text("Non disponibile")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding()
                                            }
                                            .background(Color(UIColor.tertiarySystemFill)
                                                .cornerRadius(12))
                                            .padding(.horizontal)
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
                                        
                                        if let releaseDate = show.firstAirDate, !releaseDate.isEmpty {
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
                                        
                                        if let homepage = show.homepage, !homepage.isEmpty {
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
                                        
                                        
                                        if let status = show.status, !status.isEmpty {
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
                                        
                                        if let spokenLanguages = show.languages, !spokenLanguages.isEmpty, !spokenLanguages.contains(where: { $0 == "xx" }) {
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
                                        
                                        if let productionCompanies = show.productionCompanies, !productionCompanies.isEmpty {
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
                                        
                                        if let productionCountries = show.productionCountries, !productionCountries.isEmpty {
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
                                        if let videos = show.videos?.results, !videos.isEmpty {
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
                                    
                                    if let similarShows = viewModel.similarShows, !similarShows.isEmpty {
                                        Divider()
                                        
                                        HStack(spacing: 0) {
                                            Text("Serie correlate | Fornite da:")
                                                .fontWeight(.semibold)
                                                .font(.title3)
                                                .foregroundColor(.accentColor)
                                                .padding(.horizontal)
                                            
                                            Image("tmdb_logo")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 15)
                                            
                                            Spacer()
                                        }
                                        
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            LazyHStack(spacing: 10) {
                                                ForEach(similarShows, id: \.id) { show in
                                                    NavigationLink(destination: TVShowDetailsView(showId: show.id, currentUserUid: authManager.currentUserUid)) {
                                                        if let posterPath = show.poster_path {
                                                            KFImage(URL(string: "https://image.tmdb.org/t/p/w185\(posterPath)"))
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(width: UIScreen.main.bounds.width / 4, height: (UIScreen.main.bounds.width / 4) * 1.5)
                                                                .shadow(color: .primary.opacity(0.2) , radius: 5)
                                                                .cornerRadius(10)
                                                        } else {
                                                            Image("error_404")
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(width: UIScreen.main.bounds.width / 4, height: (UIScreen.main.bounds.width / 4) * 1.5)
                                                                .shadow(color: .primary.opacity(0.2) , radius: 5)
                                                                .cornerRadius(10)
                                                        }
                                                    }
                                                }
                                            }
                                            .padding(.horizontal)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                }.transition(.move(edge: .leading))
                            case .episodes:
                                VStack {
                                    
                                    Divider()
                                    
                                    if let seasons = show.seasons {
                                        ForEach(seasons, id: \.self) { season in
                                            if season.seasonNumber != 0 && season.episodes?.count != 0 {
                                                SeasonView(season: season, viewModel: viewModel, linearGradient: Utils.linearGradient)
                                            }
                                        }
                                        if let specialSeason = seasons.first(where: { $0.seasonNumber == 0 }) {
                                            SeasonView(season: specialSeason, viewModel: viewModel, linearGradient: Utils.linearGradient)
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
                                Button(action: {
                                    viewModel.toggleTVShowToList(listName: "watching_t")
                                }) {
                                    HStack {
                                        Image(systemName: viewModel.isInList["watching_t"]! ? "eye.fill" : "eye")
                                            .foregroundStyle(Color.primary)
                                            .frame(width: 28)
                                        Text("Serie TV in visione")
                                            .foregroundStyle(Color.primary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Spacer()
                                        Image(systemName: viewModel.isInList["watching_t"]! ? "checkmark.circle.fill" : "checkmark.circle")
                                            .foregroundStyle(viewModel.isInList["watching_t"]! ? Color.mint : Color.primary)
                                            .frame(width: 28)
                                    }
                                    .padding()
                                }
                                
                                Divider()
                                
                                Button(action: {
                                    viewModel.toggleTVShowToList(listName: "watchlist")
                                }) {
                                    HStack {
                                        Image(systemName: viewModel.isInList["watchlist"]! ? "bookmark.fill" : "bookmark")
                                            .foregroundStyle(Color.primary)
                                            .frame(width: 28)
                                        Text("Watchlist")
                                            .foregroundStyle(Color.primary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Spacer()
                                        Image(systemName: viewModel.isInList["watchlist"]! ? "checkmark.circle.fill" : "checkmark.circle")
                                            .foregroundStyle(viewModel.isInList["watchlist"]! ? Color.mint : Color.primary)
                                            .frame(width: 28)
                                    }
                                    .padding()
                                }
                                
                                Divider()
                                
                                Button(action: {
                                    viewModel.toggleTVShowToList(listName: "favorite")
                                }) {
                                    HStack {
                                        Image(systemName: viewModel.isInList["favorite"]! ? "heart.fill" : "heart")
                                            .foregroundStyle(Color.primary)
                                            .frame(width: 28)
                                        Text("Preferiti")
                                            .foregroundStyle(Color.primary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Spacer()
                                        Image(systemName: viewModel.isInList["favorite"]! ? "checkmark.circle.fill" : "checkmark.circle")
                                            .foregroundStyle(viewModel.isInList["favorite"]! ? Color.mint : Color.primary)
                                            .frame(width: 28)
                                    }
                                    .padding()
                                }
                                
                                Divider()
                                
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isOtherListsPresented = true
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "list.bullet")
                                            .frame(width: 28)
                                            .foregroundStyle(Color.primary)
                                        Text("Altre liste")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(Color.primary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .frame(width: 28)
                                            .foregroundStyle(Color.primary)
                                    }
                                    .padding()
                                }
                                
                                Divider()
                                
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                        .frame(width: 28)
                                        .foregroundStyle(Color.primary)
                                    Text("Condividi")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundStyle(Color.primary)
                                    Image(systemName: "chevron.right")
                                        .frame(width: 28)
                                        .foregroundStyle(Color.primary)
                                }
                                .padding()
                                
                            } else {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isOtherListsPresented = false
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                            .foregroundStyle(Color.primary)
                                            .frame(width: 28)
                                        Text("Indietro")
                                            .foregroundStyle(Color.primary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Spacer()
                                    }
                                    .padding()
                                }
                                
                                Utils.linearGradient
                                    .frame(maxWidth: .infinity, maxHeight: 1)
                                
                                if viewModel.rawLists.count == 0 {
                                    Text("Puoi creare una lista personalizzata nel tuo profilo")
                                        .foregroundStyle(Color.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                } else {
                                    ForEach(Array(viewModel.filterRawLists().indices), id: \.self) { index in
                                        let rawList = viewModel.filterRawLists()[index]
                                        Button(action: {
                                            viewModel.toggleTVShowToList(listName: rawList.listId)
                                        }) {
                                            AddToListView(leadingIconIncluded: "checklist.checked", leadingIconNotIncluded: "checklist.unchecked", rawList: rawList, isInList: $viewModel.isInList)
                                                .padding()
                                        }
                                        
                                        if index < viewModel.filterRawLists().count - 1 {
                                            Divider()
                                        }
                                    }
                                }
                            }
                            
                            Utils.linearGradient
                                .frame(maxWidth: .infinity, maxHeight: 1)
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isListsSharePresented = false
                                }
                            }) {
                                Text("Chiudi")
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
                    await viewModel.getTVShowDetails()
                    viewModel.getSimilarTVShows()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .padding(.bottom, 1)
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
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: 100, alignment: .leading)
                    .padding(.horizontal, 4)
                    .padding(.top, 4)
                Text(castMember.character)
                    .font(.caption)
                    .lineLimit(1)
                    .frame(maxWidth: 100, alignment: .leading)
                    .padding(.horizontal, 4)
                    .padding(.top, 4)
                    .foregroundStyle(Color.secondary)
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
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: 100, alignment: .leading)
                    .padding(.horizontal, 4)
                    .padding(.top, 4)
                Text(crewMember.job)
                    .font(.caption)
                    .lineLimit(1)
                    .frame(maxWidth: 100, alignment: .leading)
                    .padding(.horizontal, 4)
                    .padding(.top, 4)
                    .foregroundStyle(Color.secondary)
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
    @ObservedObject var viewModel: TVShowDetailsViewModel
    var linearGradient: LinearGradient
    
    var body: some View {
        Button(action: { withAnimation(.easeInOut(duration: 0.2)) { viewModel.isSeasonDetailsPresented[season.seasonNumber]?.toggle() } }) {
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
                
                let seasonWatchedEpisodes = viewModel.isEpisodeWatched[season.seasonNumber]?.filter { $0.value == true }.count ?? 0
                let seasonTotalEpisodes = season.episodes?.count ?? 0
                Text("\(seasonWatchedEpisodes)/\(seasonTotalEpisodes)")
                    .foregroundStyle(Color.primary)
                
                Button(action: {
                    Task {
                        await viewModel.toggleWatchedSeason(seasonNumber: season.seasonNumber)
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(viewModel.isEpisodeWatched[season.seasonNumber]?.filter({ $0.value == true }).count == seasonTotalEpisodes ? Color.accentColor : Color(uiColor: .systemGray4))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "checkmark")
                            .foregroundStyle(viewModel.isEpisodeWatched[season.seasonNumber]?.filter({ $0.value == true }).count == seasonTotalEpisodes ? Color.primary : Color.gray)
                            .fontWeight(.medium)
                            .font(.title3)
                    }
                }
                .padding(.trailing, 10)
                .disabled(seasonTotalEpisodes == 0)
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
            get: { viewModel.isSeasonDetailsPresented[season.seasonNumber] ?? false },
            set: { newValue in viewModel.isSeasonDetailsPresented[season.seasonNumber] = newValue }
        ))
        {
            SeasonDetailsView(season: season, viewModel: viewModel, linearGradient: linearGradient)
        }
    }
}

struct SeasonDetailsView: View {
    var season: Season
    @ObservedObject var viewModel: TVShowDetailsViewModel
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
                            
                            let seasonWatchedEpisodes = viewModel.isEpisodeWatched[season.seasonNumber]?.filter { $0.value == true }.count ?? 0
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
                        EpisodeView(episode: episode, viewModel: viewModel)
                            .padding(.horizontal)
                    }
                }
            }
            .navigationTitle(season.name ?? "Stagione \(season.seasonNumber)")
        }
    }
}

struct EpisodeView: View {
    let episode: Episode
    @ObservedObject var viewModel: TVShowDetailsViewModel
    
    var body: some View {
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
                Text((episode.name == nil || (episode.name?.isEmpty ?? true)) ? "Episodio \(episode.episodeNumber)" : episode.name!)
                    .font(.callout)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.leading, -5)
            .padding(.trailing, 5)
            Spacer()
            Button(action: {
                Task {
                    await viewModel.toggleWatchedEpisode(seasonNumber: episode.seasonNumber ?? 0, episodeNumber: episode.episodeNumber, episodeRuntime: episode.runtime)
                }
            }) {
                ZStack {
                    Circle()
                        .fill(viewModel.isEpisodeWatched[episode.seasonNumber ?? 0]?[episode.episodeNumber] ?? false ? Color.accentColor : Color(uiColor: .systemGray4))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "checkmark")
                        .foregroundStyle(viewModel.isEpisodeWatched[episode.seasonNumber ?? 0]?[episode.episodeNumber] ?? false ? Color.primary : Color.gray)
                        .fontWeight(.medium)
                        .font(.title3)
                }
            }
            .padding(.trailing, 10)
        }
        .frame(height: 90)
        .background(.ultraThickMaterial)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Utils.linearGradient)
        )
        .cornerRadius(12)
    }
}
