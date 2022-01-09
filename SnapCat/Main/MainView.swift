//
//  MainView.swift
//  SnapCat
//
//  Created by Corey Baker on 7/4/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI

struct MainView: View {

    @Environment(\.tintColor) private var tintColor
    @StateObject var userStatus = UserStatus()
    @State private var selectedTab = 0

    var body: some View {

        NavigationView {
            VStack {
                NavigationLink(destination: OnboardingView(),
                               isActive: $userStatus.isLoggedOut) {
                   EmptyView()
                }

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
                        .navigationBarTitle("")
                        .navigationBarHidden(true)

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
                        .navigationBarTitle("")
                        .navigationBarHidden(true)

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
                        .navigationBarTitle("")
                        .navigationBarHidden(true)

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
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                }
            }
        }
        .environmentObject(userStatus)
        .accentColor(Color(tintColor))
        .statusBar(hidden: true)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
