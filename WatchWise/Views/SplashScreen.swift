//
//  SplashScreen.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 20/08/23.
//

import SwiftUI

struct SplashScreen: View {
    var body: some View {
        VStack {
            Image(systemName: "play")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
            Text("WatchWise")
                .font(.largeTitle)
        }
    }
}


#Preview {
    SplashScreen()
}
