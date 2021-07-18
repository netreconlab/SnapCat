//
//  SearchBarView.swift
//  SnapCat
//
//  Created by Corey Baker on 7/10/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    @State private var isEditing = false

    var body: some View {
        HStack {
            TextField("Search...", text: $searchText)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .overlay(
                    HStack {
                        /*Image(systemName: "magnifyingglass")
                            .frame(alignment: .leading)
                            .foregroundColor(.gray)
                            .padding(.leading, 0)*/
                        Spacer()
                        if isEditing {
                            Button(action: {
                                self.cancelEditing()
                            }, label: {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding()
                            })
                        }
                    }
                )
                .background(Color(.systemGray6))
                .onChange(of: searchText, perform: { value in
                    if value != "" {
                        self.isEditing = true
                    }
                })
            Spacer()
            if isEditing {
                Button(action: {
                    self.cancelEditing()
                }, label: {
                    Text("Cancel")
                        .padding()
                })
            }
        }
    }

    func cancelEditing() {
        self.isEditing = false
        self.searchText = ""
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView(searchText: .constant(""))
    }
}
