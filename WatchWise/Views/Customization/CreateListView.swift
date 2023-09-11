//
//  CreateListView.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 10/09/23.
//

import SwiftUI
import AlertToast

struct CreateListView: View {
    @StateObject var viewModel: CreateListViewModel
    @Environment(\.dismiss) var dismiss
    
    init(currentUserUid: String) {
        _viewModel = StateObject(wrappedValue: CreateListViewModel(currentUserUid: currentUserUid))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Crea una nuova lista")
                    .font(.largeTitle)
                    .foregroundStyle(Color.accentColor)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                ClearableTextField(hint: "ID lista (es.: horror_ottimi)", text: $viewModel.listId, startIcon: "number", endIcon: "xmark.circle.fill", error: $viewModel.listIdError, keyboardType: .default, textInputAutocapitalization: .never, autocorrectionDisabled: true, lowercaseText: true)
                    .padding(.horizontal)
                
                if viewModel.listIdError {
                    Text(NSLocalizedString("L'id della lista deve essere lungo tra 3 e 25 caratteri e può contenere solo lettere minuscole, numeri, \"_\" e \".\"", comment: "L'id della lista deve essere lungo tra 3 e 25 caratteri e può contenere solo lettere minuscole, numeri, \"_\" e \".\""))
                        .foregroundColor(.red)
                        .padding(.vertical, -12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .font(.footnote)
                        .padding(.horizontal)
                }
                
                ClearableTextField(hint: "Nome lista (es.: Film horror preferiti)", text: $viewModel.listName, startIcon: "signature", endIcon: "xmark.circle.fill", error: $viewModel.listNameError, keyboardType: .default, textInputAutocapitalization: .sentences, autocorrectionDisabled: false, lowercaseText: false)
                    .padding(.horizontal)
                
                if viewModel.listNameError {
                    Text(NSLocalizedString("Il nome della lista deve essere lungo tra 3 e 20 caratteri", comment: "L'id della lista deve essere lungo tra 3 e 20 caratteri"))
                        .foregroundColor(.red)
                        .padding(.vertical, -12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .font(.footnote)
                        .padding(.horizontal)
                }
                
                Picker("Tipo", selection: $viewModel.listType) {
                    Text("Film").tag("movie")
                    Text("Serie TV").tag("tv")
                    Text("Entrambi").tag("both")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                Button(action: {
                    viewModel.listIdError = false
                    viewModel.listNameError = false
                    Task {
                        await viewModel.createNewList()
                    }
                }) {
                    Text("Crea Lista")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annulla") {
                        dismiss()
                    }
                }
            }
            .toast(isPresenting: $viewModel.showLoadingToast) {
                AlertToast(displayMode: .alert, type: .loading, title: "Creazione lista in corso")
            }
            .toast(isPresenting: $viewModel.showCompletedToast) {
                AlertToast(displayMode: .alert, type: .complete(Color.accentColor), title: "Creazione lista completata")
            } completion: {
                dismiss()
            }
        }
    }
}
