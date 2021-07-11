//
//  PostView.swift
//  SnapCat
//
//  Created by Corey Baker on 7/11/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI
import ParseSwift

struct PostView: View {
    @ObservedObject var viewModel = PostViewModel()
    @State private var isShowingImagePicker = true
    var body: some View {
        NavigationView {
            Text("Hello, World!")
        }.sheet(isPresented: $isShowingImagePicker, onDismiss: {}, content: {
            ImagePickerView(image: $viewModel.image)
        })
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView()
    }
}
