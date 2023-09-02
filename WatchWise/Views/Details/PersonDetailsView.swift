//
//  PersonDetailsView.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 02/09/23.
//

import SwiftUI
import Kingfisher
import ExpandableText

enum CreditsTabs: String, CaseIterable {
    case cast = "Come cast"
    case crew = "Come staff"
    
    var localized: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

struct PersonDetailsView: View {
    @EnvironmentObject var authManager: AuthManager
    @ObservedObject var viewModel: PersonDetailsViewModel
    
    @State var offset: CGFloat = 0
    @State private var selectedCreditsTab = CreditsTabs.cast
    @Environment(\.presentationMode) var presentationMode
    
    init(personId: Int32) {
        self.viewModel = PersonDetailsViewModel(personId: personId)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if let person = viewModel.person {
                    OffsetScrollView(offset: $offset, showIndicators: true, axis: .vertical) {
                        VStack {
                            ZStack {
                                GeometryReader { proxy in
                                    if let profilePath = person.profilePath {
                                        KFImage(URL(string: "https://image.tmdb.org/t/p/original\(profilePath)"))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: UIScreen.main.bounds.width,
                                                   height: max(proxy.size.height - offset, UIScreen.main.bounds.width))
                                            .clipped()
                                            .offset(y: min(offset, 0))
                                            .shadow(color: Color.secondary, radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                                    } else {
                                        Image("error_404")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: UIScreen.main.bounds.width,
                                                   height: max(proxy.size.height - offset, UIScreen.main.bounds.width))
                                            .clipped()
                                            .offset(y: min(offset, 0))
                                            .shadow(color: .secondary, radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                                    }
                                }
                                .frame(height: UIScreen.main.bounds.width)
                            }
                            Text(person.name)
                                .bold()
                                .font(.largeTitle)
                                .foregroundStyle(Color.accentColor)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            if let biography = person.biography, !biography.isEmpty {
                                ExpandableText(biography)
                                    .lineLimit(4)
                                    .moreButtonText("altro")
                                    .padding(.horizontal)
                            }
                            
                            Divider()
                            
                            if let birthday = person.birthday, !birthday.isEmpty {
                                Text("Data di nascita")
                                    .fontWeight(.semibold)
                                    .font(.title2)
                                    .foregroundStyle(Color.accentColor)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                
                                Text(Utils.formatDateToLocalString(dateString: birthday)!)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                            }
                            
                            if let placeOfBirth = person.placeOfBirth, !placeOfBirth.isEmpty {
                                Text("Luogo di nascita")
                                    .fontWeight(.semibold)
                                    .font(.title2)
                                    .foregroundStyle(Color.accentColor)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 2)
                                    .padding(.horizontal)
                                
                                Text(placeOfBirth)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                            }
                            
                            if let deathday = person.deathday, !deathday.isEmpty {
                                Text("Data di morte")
                                    .fontWeight(.semibold)
                                    .font(.title2)
                                    .foregroundStyle(Color.accentColor)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 2)
                                    .padding(.horizontal)
                                
                                Text(Utils.formatDateToLocalString(dateString: deathday)!)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                            }
                            
                            if let gender = person.gender, gender != 0 {
                                Text("Genere")
                                    .fontWeight(.semibold)
                                    .font(.title2)
                                    .foregroundStyle(Color.accentColor)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 2)
                                    .padding(.horizontal)
                                
                                let genderString = switch gender {
                                case 1: "Femminile"
                                case 2: "Maschile"
                                case 3: "Non binario"
                                default: "Non disponibile"
                                }
                                
                                Text(genderString)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                            }
                            
                            if let knownForDepartment = person.knownForDepartment, !knownForDepartment.isEmpty {
                                Text("Conosciuto per")
                                    .fontWeight(.semibold)
                                    .font(.title2)
                                    .foregroundStyle(Color.accentColor)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 2)
                                    .padding(.horizontal)
                                
                                Text(knownForDepartment)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                            }
                            
                            if let homepage = person.homepage, !homepage.isEmpty {
                                Button(action: {
                                    if let url = URL(string: homepage) {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.up.forward.app")
                                        Text(NSLocalizedString("Vai al sito web", comment: "Vai al sito web"))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                            
                            if let credits = person.credits {
                                if let cast = credits.cast, let crew = credits.crew {
                                    if !cast.isEmpty && !crew.isEmpty {
                                        Divider()
                                        
                                        Text("Partecipazioni")
                                            .fontWeight(.semibold)
                                            .font(.title2)
                                            .foregroundStyle(Color.accentColor)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal)
                                        
                                        Picker("Partecipazioni", selection: $selectedCreditsTab) {
                                            ForEach(CreditsTabs.allCases, id: \.self) { tab in
                                                Text(tab.localized).tag(tab)
                                            }
                                        }
                                        .pickerStyle(.segmented)
                                        .padding(.horizontal)
                                        
                                        switch selectedCreditsTab {
                                        case .cast:
                                            ProductsView(products: cast)
                                        case .crew:
                                            ProductsView(products: crew)
                                        }
                                    } else if !cast.isEmpty && crew.isEmpty {
                                        Text("Partecipazioni")
                                            .fontWeight(.semibold)
                                            .font(.title2)
                                            .foregroundStyle(Color.accentColor)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal)
                                        
                                        ProductsView(products: cast)
                                    } else if cast.isEmpty && !crew.isEmpty {
                                        Text("Partecipazioni")
                                            .fontWeight(.semibold)
                                            .font(.title2)
                                            .foregroundStyle(Color.accentColor)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal)
                                        
                                        ProductsView(products: crew)
                                    }
                                }
                            }
                        }
                    }
                    .ignoresSafeArea(edges: .top)
                    .overlay(
                        NavigationBar(title: person.name, offset: $offset, startOffset: 400, endOffset: 450) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                } else {
                    ProgressView("Caricamento in corso...")
                        .progressViewStyle(.circular)
                        .tint(.accentColor)
                        .controlSize(.large)
                }
            }
            .onAppear {
                viewModel.getPersonDetails()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct ProductsView: View {
    var products: [Product]
    
    var body: some View {
        LazyVStack {
            ForEach(products.indices, id: \.self) { index in
                if index > 0 {
                    Divider()
                        .padding(.horizontal)
                }
                NavigationLink(destination: products[index].mediaType == "movie" ? AnyView(MovieDetailsView(movieId: products[index].id)) : AnyView(TVShowDetailsView(showId: products[index].id))) {
                    HStack(spacing: 0) {
                        if let posterPath = products[index].posterPath {
                            KFImage(URL(string: "https://image.tmdb.org/t/p/w92\(posterPath)"))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 65, height: 65)
                                .cornerRadius(10)
                                .padding(.vertical, 10)
                                .padding(.leading, 10)
                        }
                        VStack {
                            Text(products[index].mediaType == "movie" ? products[index].title! : products[index].name!)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(1)
                            if let character = products[index].character, !character.isEmpty {
                                Text(character)
                                    .font(.caption)
                                    .foregroundStyle(Color.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                            } else if let job = products[index].job, !job.isEmpty {
                                Text(job)
                                    .font(.caption)
                                    .foregroundStyle(Color.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                            }
                        }
                        .padding()
                        Image(systemName: "chevron.right")
                            .padding(.horizontal)
                            .foregroundStyle(Color.secondary)
                    }
                }
            }
        }
        .background(Color(UIColor.tertiarySystemFill)
        .cornerRadius(12))
        .padding(.horizontal)
    }
}

#Preview {
    PersonDetailsView(personId: 380)
}
