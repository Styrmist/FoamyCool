//
//  BeerItem.swift
//  FoamyCool
//
//  Created by Kyrylo Danylov on 9/28/19.
//  Copyright © 2019 Kyrylo Danylov. All rights reserved.
//

import Foundation

struct BeerItem: Codable {
    let id: String
    let name: String
    let description: String?
    let style: BeerStyle?
    let labels: BeerIcons?
}

struct BeerStyle: Codable {
    let id: Int
    let name: String
    let shortName: String?
}

struct BeerIcons: Codable {
    let icon: String
    let medium: String
    let large: String
}
