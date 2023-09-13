//
//  ChangeBackdropView.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 11/09/23.
//

import SwiftUI
import Kingfisher

struct ChangeBackdropView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ChangeBackdropViewModel
    
    @Binding var selectedBackdrop: String
    
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    init(currentUserUid: String, selectedImage: Binding<String>) {
        self.viewModel = ChangeBackdropViewModel(currentUserUid: currentUserUid)
        self._selectedBackdrop = selectedImage
    }
    
    var body: some View {
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
                
                Text("Immagine di sfondo")
                    .foregroundStyle(Color.accentColor)
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 8)
                
                Spacer()
                
                Button {
                    self.selectedBackdrop = "https://firebasestorage.googleapis.com/v0/b/watchwise-tesi.appspot.com/o/desert.jpg?alt=media&token=0b21bfaf-1e8a-4d25-95c7-df439fae20ee"
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 36, height: 36)
                        .tint(.red)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(viewModel.backdropImages, id: \.self) { imageUrl in
                        KFImage(URL(string: imageUrl))
                            .resizable()
                            .aspectRatio(16 / 9, contentMode: .fit)
                            .onTapGesture {
                                viewModel.selectImage(imageUrl)
                            }
                            .frame(width: (UIScreen.main.bounds.width / 2) - 24)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(viewModel.selectedImage == imageUrl ? Color.accentColor : Color.clear, lineWidth: 2)
                            )
                    }
                }
            }
            
            if let selected = viewModel.selectedImage {
                Button(action: {
                    self.selectedBackdrop = selected
                    dismiss()
                }) {
                        Text("Conferma")
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(.horizontal)
    }
}
