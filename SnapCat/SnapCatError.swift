//
//  SnapCatError.swift
//  SnapCat
//
//  Created by Corey Baker on 7/3/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import ParseSwift

public struct SnapCatError: Swift.Error {

    public let message: String

    public var localizedDescription: String {
        return "AssuageError error=\(message)"
    }
}

extension SnapCatError {
    init(parseError: ParseError) {
        message = parseError.description
    }
}
