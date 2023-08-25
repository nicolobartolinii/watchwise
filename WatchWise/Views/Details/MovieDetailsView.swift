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
    
    @State private var laude = false
    
    @State private var review = ""
    
    @State private var reviewError = false
    
    @State private var selectedInfoTab = InfoTabs.cast
    
    @State private var showNavigationBar: Bool = false
    
    var body: some View {
        NavigationView {
            OffsetScrollView(offset: $offset, showIndicators: true, axis: .vertical) {
                VStack {
                    ZStack {
                        GeometryReader { proxy in
                            if let backdropPath = movie?.backdrop_path {
                                KFImage(URL(string: "https://image.tmdb.org/t/p/w1280\(backdropPath)"))
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
                    
                    HStack(alignment: .top) {
                        if let posterPath = movie?.poster_path {
                            KFImage(URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)"))
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width / 3, height: (UIScreen.main.bounds.width / 3) * 1.5)
                                .cornerRadius(10)
                                .shadow(color: .secondary, radius: 5)
                                .offset(y: -40)
                        } else {
                            Image("error_404")
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width / 3, height: (UIScreen.main.bounds.width / 3) * 1.5)
                                .cornerRadius(10)
                                .shadow(color: .secondary, radius: 5)
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
                    
                    let genres = movie?.genres.map { $0.name } ?? []
                    
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
                    
                    if let providers = movie?.watchProviders {
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
                    
                    ExpandableText(movie?.overview ?? "Non disponibile")
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
                        if let cast = movie?.credits?.cast {
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(cast, id: \.self) { castMember in
                                        castView(castMember: castMember)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    case .crew:
                        if let crew = movie?.credits?.crew.prefix(30) {
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(crew, id: \.self) { crewMember in
                                        crewView(crewMember: crewMember)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    case .details:
                        EmptyView()
                    case .videos:
                        EmptyView()
                    }
                }
            }
            .ignoresSafeArea()
            .onAppear {
                getMovieDetails()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    CustomNavigationBar(
                        showNavigationBar: showNavigationBar,
                        movieTitle: movie?.title
                    )
                }
            }
            .animation(.easeInOut, value: showNavigationBar)
        }
        .onReceive(offset) { newOffset in
            // Logica per determinare quando mostrare la barra degli strumenti
            showNavigationBar = newOffset > 130
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
        .background(Color(UIColor.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 4)
        .padding(.vertical, 8)
    }
    
    func crewView(crewMember: Crew) -> some View {
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
        .background(Color(UIColor.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 4)
        .padding(.vertical, 8)
    }
    
}

#Preview {
    MovieDetailsView(movieId: 872585) // 872585, 299564, 299536
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

struct CustomNavigationBar: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let showNavigationBar: Bool
    let movieTitle: String?
    
    var body: some View {
        HStack {
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left") // Pulsante Indietro
            }
            Spacer()
            Text(movieTitle ?? "Non disponibile") // Titolo del film
                .opacity(showNavigationBar ? 1 : 0)
            Spacer()
        }
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
