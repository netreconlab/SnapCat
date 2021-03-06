//
//  TintColorKey.swift
//  SnapCat
//
//  Created by Corey Baker on 1/8/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import SwiftUI

struct TintColorKey: EnvironmentKey {

    static var defaultValue: UIColor {
        UIColor { $0.userInterfaceStyle == .light ?  #colorLiteral(red: 0, green: 0.2858072221, blue: 0.6897063851, alpha: 1) : #colorLiteral(red: 0.06253327429, green: 0.6597633362, blue: 0.8644603491, alpha: 1) }
    }
}

extension EnvironmentValues {

    var tintColor: UIColor {
        self[TintColorKey.self]
    }
}
