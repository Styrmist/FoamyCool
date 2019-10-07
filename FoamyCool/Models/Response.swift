//
//  Response .swift
//  FoamyCool
//
//  Created by Kyrylo Danylov on 9/29/19.
//  Copyright © 2019 Kyrylo Danylov. All rights reserved.
//

import Foundation

struct SearchBeerResponse: Codable {
    let currentPage: Int?
    let numberOfPages: Int?
    let data: [BeerItem]?
    let status: String
}

struct SearchBreweryResponse: Codable {
    let currentPage: Int?
    let numberOfPages: Int?
    let data: [BreweryItem]?
    let status: String
}

struct GetBeerByIdResponse: Codable {
    let message: String?
    let data: BeerItem?
    let status: String
}
