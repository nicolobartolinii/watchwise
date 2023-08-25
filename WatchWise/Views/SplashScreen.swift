//
//  SplashScreen.swift
//  WatchWise
//
//  Created by Nicolò Bartolini on 20/08/23.
//

import SwiftUI

struct SplashScreen: View {
    var body: some View {
        Image("logo_title")
            .resizable()
            .scaledToFit()
            .frame(width: UIScreen.main.bounds.width - 200)
    }
}


#Preview {
    SplashScreen()
}
