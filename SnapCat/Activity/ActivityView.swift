//
//  ActivityView.swift
//  SnapCat
//
//  Created by Corey Baker on 7/4/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI

struct ActivityView: View {
    @ObservedObject var followingsActivityViewModel = ActivityViewModel
        .queryFollowingsActivity
        .include(ActivityKey.fromUser)
        .viewModel

    var body: some View {
        NavigationView {
            if !followingsActivityViewModel.results.isEmpty {
                List(followingsActivityViewModel.results, id: \.id) { result in
                    VStack(alignment: .leading) {
                        Text("\(result.updatedAt!.description)")
                            .font(.headline)
                        if let createdAt = result.createdAt {
                            Text(createdAt.relativeTime)
                        }
                    }
                }
                Spacer()
            } else {
                EmptyActivityView()
            }
        }.onAppear(perform: {
            followingsActivityViewModel.find()
        })
    }

    init () {
        followingsActivityViewModel.find()
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView()
    }
}
