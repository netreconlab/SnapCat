//
//  FollowButtonStyle.swift
//  SnapCat
//
//  Created by Corey Baker on 7/20/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import SwiftUI

struct FollowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(.white)
            .background(configuration.isPressed ? Color(#colorLiteral(red: 0.06253327429, green: 0.6597633362, blue: 0.8644603491, alpha: 1)) : Color(#colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)))
            .cornerRadius(20.0)
    }
}
