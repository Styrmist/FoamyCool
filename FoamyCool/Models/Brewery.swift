//
//  Brewery.swift
//  FoamyCool
//
//  Created by Kyrylo Danylov on 9/28/19.
//  Copyright © 2019 Kyrylo Danylov. All rights reserved.
//

import Foundation

struct BreweryItem: Codable {
    let breweryId: String
    let name: String
    let brewery: BreweryStyle?
}

struct BreweryStyle: Codable {
    let id: String
    let description: String?
    let images: BreweryIcons?
}

struct BreweryIcons: Codable {
    let icon: String
    let medium: String
    let squareMedium: String
}
