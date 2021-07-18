//
//  MainView.swift
//  SnapCat
//
//  Created by Corey Baker on 7/4/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI

struct MainView: View {
    @State private var selectedTab = 0
    @State private var tintColor = UIColor { $0.userInterfaceStyle == .light ?  #colorLiteral(red: 0, green: 0.2858072221, blue: 0.6897063851, alpha: 1) : #colorLiteral(red: 0.06253327429, green: 0.6597633362, blue: 0.8644603491, alpha: 1) }
    var body: some View {

        // User has to be logged in to use the app.
        if User.current == nil {
            OnboardingView()
        } else {

            TabView(selection: $selectedTab) {

                HomeView()
                    .tabItem {
                        if selectedTab == 0 {
                            Image(systemName: "house.fill")
                                .renderingMode(.template)
                        } else {
                            Image(systemName: "house")
                                .renderingMode(.template)
                        }
                    }
                    .tag(0)

                ExploreView()
                    .tabItem {
                        if selectedTab == 1 {
                            Image(systemName: "magnifyingglass.circle.fill")
                                .renderingMode(.template)
                        } else {
                            Image(systemName: "magnifyingglass.circle")
                                .renderingMode(.template)
                        }
                    }
                    .tag(1)

                ActivityView()
                    .tabItem {
                        if selectedTab == 2 {
                            Image(systemName: "heart.fill")
                                .renderingMode(.template)
                        } else {
                            Image(systemName: "heart")
                                .renderingMode(.template)
                        }
                    }
                    .tag(2)

                ProfileView()
                    .tabItem {
                        if selectedTab == 3 {
                            Image(systemName: "person.fill")
                                .renderingMode(.template)
                        } else {
                            Image(systemName: "person")
                                .renderingMode(.template)
                        }
                    }
                    .tag(3)
            }
            .accentColor(Color(tintColor))
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
