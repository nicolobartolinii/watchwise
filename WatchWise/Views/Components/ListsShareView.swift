//
//  ListsShareView.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 27/08/23.
//

import SwiftUI

struct ListRow: View {
    let icon: String
    let title: String
    var showNextPageIcon: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 28)
            Text(title)
            Spacer()
            if showNextPageIcon {
                Image(systemName: "chevron.right")
            }
        }
    }
}

