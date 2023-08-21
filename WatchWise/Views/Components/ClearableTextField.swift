//
//  ClearableTextField.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 20/08/23.
//

import SwiftUI

struct ClearableTextField: View {
    var hint: String
    @Binding var text: String
    var startIcon: String
    var endIcon: String
    @State private var isPressed: Bool = false
    @Binding var error: Bool
    
    var body: some View {
        HStack {
            if startIcon != "" {
                Image(systemName: startIcon)
                    .frame(width: 24, height: 24)
                    .foregroundColor(error ? .red : .primary)
            }
            TextField(hint, text: $text)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .autocorrectionDisabled(true)
            if !text.isEmpty {
                Button(action: {
                    self.text = ""
                }) {
                    Image(systemName: endIcon)
                        .foregroundColor(error ? .red : .gray)
                        .scaleEffect(isPressed ? 0.7 : 1)
                        .animation(.easeInOut(duration: 0.2), value: isPressed)
                        .frame(width: 24, height: 24)
                }
                .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
                    self.isPressed = pressing
                }, perform: {})
            }
            if text.isEmpty && error {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.red)
                    .frame(width: 24, height: 24)
            }
        }
        .padding()
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(error ? .red : .gray, lineWidth: 1))
    }
}
