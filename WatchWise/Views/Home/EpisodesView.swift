//
//  EpisodesView.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 19/08/23.
//

import SwiftUI
import Kingfisher

struct EpisodesView: View {
    @EnvironmentObject var authManager: AuthManager
    @ObservedObject var viewModel: EpisodesViewModel
    @State private var selectedShowId: Int64? = nil
    @State private var shouldNavigate: Bool = false
    
    init(currentUserUid: String) {
        self.viewModel = EpisodesViewModel(currentUserUid: currentUserUid)
    }
    
    var body: some View {
        NavigationView {
            if let nextEpisodes = viewModel.nextEpisodes {
                VStack(spacing: 0) {
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
                    
                    Text("Episodi")
                        .font(.title)
                        .foregroundColor(.accentColor)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    List(Array(nextEpisodes.enumerated()), id: \.offset) { index, nextEpisode in
                        NavigationLink(destination: TVShowDetailsView(showId: nextEpisode.showId, currentUserUid: authManager.currentUserUid)) {
                            HStack(alignment: .center) {
                                if let posterPath = nextEpisode.posterPath {
                                    KFImage(URL(string: "https://image.tmdb.org/t/p/w185\(posterPath)"))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 70, height: 105)
                                        .cornerRadius(10)
                                } else {
                                    Image("error_404")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 70, height: 105)
                                        .cornerRadius(10)
                                }
                                VStack {
                                    Text(nextEpisode.showName)
                                        .bold()
                                        .foregroundStyle(Color.accentColor)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(.title3)
                                        .lineLimit(1)
                                    HStack(spacing: 0) {
                                        Text("S\(Utils.convertSeasonEpisodeNumber(nextEpisode.seasonNumber)) | ")
                                            .fontWeight(.semibold)
                                        
                                        Text("E\(Utils.convertSeasonEpisodeNumber(nextEpisode.episodeNumber))")
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    Text(nextEpisode.episodeName.isEmpty ? "Episodio \(nextEpisode.episodeNumber)" : nextEpisode.episodeName)
                                        .font(.callout)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Spacer()
                                }
                                .padding(.vertical, 5)
                                Spacer()
                                Button(action: {
                                    Task {
                                        await viewModel.watchEpisode(showId: nextEpisode.showId, seasonNumber: nextEpisode.seasonNumber, episodeNumber: nextEpisode.episodeNumber, episodeRuntime: (nextEpisode.duration == nil || nextEpisode.duration == 0 ? 30 : nextEpisode.duration!))
                                    }
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(uiColor: .systemGray4))
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(Color.gray)
                                            .fontWeight(.medium)
                                            .font(.title3)
                                    }
                                }.buttonStyle(.plain)
                            }
                        }
                    }
                    .refreshable {
                        Task {
                            try await viewModel.loadNextEpisodes()
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
        .onAppear(perform: {
            Task {
                try await viewModel.loadNextEpisodes()
            }
        })
    }
}

#Preview {
    EpisodesView(currentUserUid: "egcf4FX5jDY5dbUeF3qZs1d6mQA3")
}
