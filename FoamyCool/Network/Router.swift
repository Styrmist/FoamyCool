//
//  Router.swift
//  FoamyCool
//
//  Created by Kyrylo Danylov on 9/28/19.
//  Copyright © 2019 Kyrylo Danylov. All rights reserved.
//

import Foundation

enum Router {
    case searchForBeer(_: String, page: Int)
    case getBeerBy(id: String)
    case getBeersForBreweryBy(id: String)
    case getBreweriesByLocation(lat: String, lng: String)

    var scheme: String {
        return "https"
    }

    var host: String {
        return "sandbox-api.brewerydb.com"
    }

    var method: String {
        return "GET"	
    }

    var apiVersion: String {
        return "/v2"
    }

    var path: String {
        switch self {
        case .searchForBeer:
            return apiVersion + "/search"
        case .getBeerBy(let id):
            return apiVersion + "/beer/\(id)"
        case .getBeersForBreweryBy(let id):
            return apiVersion + "/brewery/\(id)/beers"
        case .getBreweriesByLocation:
            return apiVersion + "/search/geo/point"
        }
    }

    var parameters: [URLQueryItem] {
        let accessKey = "20bb8d55cb693c11b4ce1d581f390f32"
        switch self {
        case .searchForBeer(let query, let page):
            return [URLQueryItem(name: "p", value: String(page)),
                    URLQueryItem(name: "q", value: query),
                    URLQueryItem(name: "type", value: "beer"),
                    URLQueryItem(name: "key", value: accessKey)]
        case .getBeerBy:
            return [URLQueryItem(name: "key", value: accessKey)]
        case .getBeersForBreweryBy:
            return [URLQueryItem(name: "key", value: accessKey)]
        case .getBreweriesByLocation(let lat, let lng):
            return [URLQueryItem(name: "lat", value: lat),
                    URLQueryItem(name: "lng", value: lng),
                    URLQueryItem(name: "radius", value: "100"),
                    URLQueryItem(name: "key", value: accessKey)]
        }
    }
}
