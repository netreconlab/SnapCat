//
//  HomeView.swift
//  SnapCat
//
//  Created by Corey Baker on 7/4/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI
import ParseSwift

struct HomeView: View {

    @State private var tintColor = UIColor { $0.userInterfaceStyle == .light ?  #colorLiteral(red: 0, green: 0.2858072221, blue: 0.6897063851, alpha: 1) : #colorLiteral(red: 0.06253327429, green: 0.6597633362, blue: 0.8644603491, alpha: 1) }

    var body: some View {
        VStack {
            HStack {
                Text("SnapCat")
                    .font(Font.custom("noteworthy-bold", size: 30))
                    .foregroundColor(Color(tintColor))
                    .padding()
                Spacer()
                Button(action: {

                }, label: {
                    Image(systemName: "square.and.pencil")
                        .resizable()
                        .foregroundColor(Color(tintColor))
                        .frame(width: 30, height: 30, alignment: .trailing)
                        .padding()
                })
            }
            Divider()
            TimeLineView()
            Spacer()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
