//
//  CloudImageViewModel.swift
//  SnapCat
//
//  Created by Corey Baker on 7/12/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import ParseSwift

class CloudImageViewModel<T: ParseCloud>: CloudViewModel<T> {

    override var results: T.ReturnType? {
        willSet {

        }
    }
}
