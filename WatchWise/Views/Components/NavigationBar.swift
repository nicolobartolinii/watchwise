//
//  NavigationBar.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 26/08/23.
//

import SwiftUI

struct NavigationBar: View {
    var title = ""
    @Binding var offset: CGFloat
    var startOffset: CGFloat = 175
    var endOffset: CGFloat = 225
    var action: () -> Void
    
    var body: some View {
        ZStack {
            Color.clear
                .background(.thinMaterial)
                .opacity(getOpacity(from: offset))
            
            HStack {
                Button(action: action) {
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
                .padding(.leading)
                
                Text(title)
                    .font(.title)
                    .foregroundColor(.accentColor)
                    .bold()
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 8)
                    .opacity(getOpacity(from: offset))
            }
        }
        .frame(height: 70)
        .frame(maxHeight: .infinity, alignment: .top)
    }
    
    private func getOpacity(from offset: CGFloat) -> Double {
        let opacity = (offset - startOffset) / (endOffset - startOffset)
        
        return Double(min(max(opacity, 0), 1))
    }
}
