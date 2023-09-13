//
//  EditProfileView.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 11/09/23.
//

import SwiftUI
import PhotosUI
import Kingfisher
import AlertToast

private enum FocusField: Int, CaseIterable {
    case displayName
}

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var viewModel: EditProfileViewModel
    
    @State private var profileImage: PhotosPickerItem? = nil
    @State private var backdropImage: String
    @State private var selectedImage: UIImage? = nil
    @State private var data: Data?
    @State private var isBackdropViewPresented: Bool = false
    @State private var defaultPropicColor: Color = Color.cyan
    
    private var systemColors: [Color] = [.blue, .green, .yellow, .purple, .cyan, .brown, .gray, .orange, .pink, .indigo, .mint, .teal]
    
    @FocusState private var focusState: FocusField?
    
    init(user: User) {
        self.viewModel = EditProfileViewModel(user: user)
        self._backdropImage = State(initialValue: user.backdropPath)
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
                
                Text("Modifica il tuo profilo")
                    .foregroundStyle(Color.accentColor)
                    .font(.title)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding(.horizontal)
            
            ScrollView {
                Text("Cambia il tuo nome visualizzato")
                    .foregroundStyle(Color.primary)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                HStack {
                    ClearableTextField(hint: "Nome visualizzato", text: $viewModel.displayName, startIcon: "person", endIcon: "xmark.circle.fill", error: $viewModel.displayNameError, keyboardType: .default, autocorrectionDisabled: false)
                        .focused($focusState, equals: .displayName)
                        .toolbar {
                            ToolbarItem(placement: .keyboard) {
                                Button("Fatto") {
                                    focusState = nil
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    
                    Button {
                        Task {
                            viewModel.displayNameError = false
                            await viewModel.changeDisplayName()
                        }
                    } label: {
                        Text(NSLocalizedString("Conferma", comment: "Conferma"))
                            .frame(height: 40)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.displayName == viewModel.oldDisplayName)
                    
                }
                .padding(.horizontal)
                
                if viewModel.displayNameError {
                    Text(NSLocalizedString("Il nome visualizzato deve essere lungo tra 3 e 30 caratteri", comment: "Inserisci un nome visualizzato valido"))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.footnote)
                        .padding(.horizontal)
                        .multilineTextAlignment(.leading)
                }
                
                Divider()
                
                Text("Cambia la tua immagine di profilo")
                    .foregroundStyle(Color.primary)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                if let data = data, let uiimage = UIImage(data: data) {
                    ZStack {
                        PhotosPicker(selection: $profileImage, matching: .images) {
                            Image(uiImage: uiimage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipShape(Circle())
                        }.onChange(of: profileImage) { newValue in
                            guard let item = profileImage else {
                                return
                            }
                            item.loadTransferable(type: Data.self) { result in
                                switch result {
                                case .success(let data):
                                    if let data = data {
                                        self.data = data
                                        self.selectedImage = UIImage(data: data)
                                    } else {
                                        print ("Data is nil")
                                    }
                                case .failure(let failure):
                                    fatalError("\(failure)")
                                }
                            }
                        }
                        Button {
                            self.data = nil
                            viewModel.profileImage = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 36, height: 36)
                                .tint(.red)
                        }
                        .offset(x: 125, y: 0)
                    }
                    .padding(.horizontal)
                } else {
                    ZStack {
                        PhotosPicker(selection: $profileImage, matching: .images) {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 150, height: 150)
                                .foregroundStyle(defaultPropicColor)
                        }.onChange(of: profileImage) { newValue in
                            guard let item = profileImage else {
                                return
                            }
                            item.loadTransferable(type: Data.self) { result in
                                switch result {
                                case .success(let data):
                                    if let data = data {
                                        self.data = data
                                        self.selectedImage = UIImage(data: data)
                                    } else {
                                        print ("Data is nil")
                                    }
                                case .failure(let failure):
                                    fatalError("\(failure)")
                                }
                            }
                        }
                        Button {
                            defaultPropicColor = systemColors.randomElement()!
                        } label: {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .resizable()
                                .frame(width: 36, height: 36)
                                .tint(defaultPropicColor)
                        }
                        .offset(x: 125, y: 0)
                    }
                    .padding(.horizontal)
                }
                
                Button {
                    if selectedImage == nil {
                        setupUIImage()
                    } else {
                        viewModel.profileImage = selectedImage
                    }
                    Task {
                        await viewModel.changeProfileImage()
                    }
                } label: {
                    Text(NSLocalizedString("Conferma", comment: "Conferma"))
                }
                .buttonStyle(.borderedProminent)
                
                Divider()
                
                Text("Cambia la tua immagine di sfondo")
                    .foregroundStyle(Color.primary)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                Button(action: {
                    isBackdropViewPresented = true
                }) {
                    KFImage(URL(string: self.backdropImage))
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width - 32, height: (UIScreen.main.bounds.width - 32) * 9 / 16)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .sheet(isPresented: $isBackdropViewPresented, onDismiss: { viewModel.backdropImage = self.backdropImage }, content: {
                    ChangeBackdropView(currentUserUid: viewModel.user.uid, selectedImage: $backdropImage)
                })
                
                Button {
                    Task {
                        viewModel.showBackdropImageLoadingAlert = true
                        await viewModel.changeUserField(field: "backdropPath", value: self.backdropImage)
                        viewModel.showBackdropImageLoadingAlert = false
                        viewModel.showBackdropImageCompletedAlert = true
                    }
                } label: {
                    Text(NSLocalizedString("Conferma", comment: "Conferma"))
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toast(isPresenting: $viewModel.showDisplayNameLoadingAlert) {
            AlertToast(displayMode: .alert, type: .loading, title: "Modifica del nome visualizzato in corso...")
        }
        .toast(isPresenting: $viewModel.showDisplayNameCompletedAlert) {
            AlertToast(displayMode: .alert, type: .complete(Color.accentColor), title: "Nome visualizzato modificato")
        }
        .toast(isPresenting: $viewModel.showProfileImageLoadingAlert) {
            AlertToast(displayMode: .alert, type: .loading, title: "Modifica dell'immagine di profilo in corso...")
        }
        .toast(isPresenting: $viewModel.showProfileImageCompletedAlert) {
            AlertToast(displayMode: .alert, type: .complete(Color.accentColor), title: "Immagine di profilo modificata")
        }
        .toast(isPresenting: $viewModel.showBackdropImageLoadingAlert) {
            AlertToast(displayMode: .alert, type: .loading, title: "Modifica dell'immagine di sfondo in corso...")
        }
        .toast(isPresenting: $viewModel.showBackdropImageCompletedAlert) {
            AlertToast(displayMode: .alert, type: .complete(Color.accentColor), title: "Immagine di sfondo modificata")
        }
    }
    
    func setupUIImage() {
        let currentImage = UIImage(systemName: "person.circle.fill")!.withTintColor(UIColor(defaultPropicColor))
        let newSize = CGSize(width: 300, height: 300)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        currentImage.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        viewModel.profileImage = resizedImage
    }
}
