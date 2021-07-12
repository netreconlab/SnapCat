//
//  TimeLineView.swift
//  SnapCat
//
//  Created by Corey Baker on 7/5/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI
import ParseSwift
import os.log
import UIKit

struct TimeLineView: View {

    @State private var tintColor = UIColor { $0.userInterfaceStyle == .light ?  #colorLiteral(red: 0, green: 0.2858072221, blue: 0.6897063851, alpha: 1) : #colorLiteral(red: 0.06253327429, green: 0.6597633362, blue: 0.8644603491, alpha: 1) }
    @ObservedObject var timeLineViewModel: QueryViewModel<Post>

    var body: some View {
        NavigationView {
            if !timeLineViewModel.results.isEmpty {
                List(timeLineViewModel.results, id: \.objectId) { result in
                    VStack(alignment: .leading) {
                        /*self.fetchImage(result.image) { image in
                            if let image = image {
                                Image(uiImage: uiImage)
                            }
                        }*/
                        if let caption = result.caption {
                            Text(caption)
                        }
                        if let createdAt = result.createdAt {
                            Text(createdAt.relativeTime)
                        }
                    }
                }
            } else {
                EmptyTimeLineView()
            }
            Spacer()
        }.onAppear(perform: {
            timeLineViewModel.find()
        })
    }

    init(viewModel: QueryViewModel<Post>? = nil) {
        guard let viewModel = viewModel else {
            timeLineViewModel = TimeLineViewModel.queryTimeLine().viewModel
            timeLineViewModel.find()
            return
        }
        timeLineViewModel = viewModel
    }

    func fetchImage(_ file: ParseFile?, completion: @escaping (UIImage?) -> Void) {
        guard let file = file else {
            let image = UIImage(systemName: "camera")
            completion(image)
            return
        }
        file.fetch { result in
            switch result {
            case .success(let image):
                if let path = image.localURL?.relativePath {
                    let image = UIImage(contentsOfFile: path)
                    completion(image)
                } else {
                    let image = UIImage(systemName: "camera")
                    completion(image)
                }
            case .failure(let error):
                Logger.home.error("Error fetching picture: \(error)")
            }
        }
    }
}

struct TimeLineView_Previews: PreviewProvider {
    static var previews: some View {
        TimeLineView()
    }
}
