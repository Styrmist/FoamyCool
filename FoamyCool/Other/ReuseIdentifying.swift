//
//  ReuseIdentifier.swift
//  FoamyCool
//
//  Created by Kyrylo Danylov on 9/28/19.
//  Copyright © 2019 Kyrylo Danylov. All rights reserved.
//

import Foundation

protocol ReuseIdentifying {
    static var reuseIdentifier: String { get }
}

extension ReuseIdentifying {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}
