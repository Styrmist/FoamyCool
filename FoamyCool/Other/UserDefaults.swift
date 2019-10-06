//
//  UserDefaults.swift
//  FoamyCool
//
//  Created by Kyrylo Danylov on 10/6/19.
//  Copyright © 2019 Kyrylo Danylov. All rights reserved.
//

import Foundation

extension UserDefaults {
    @objc dynamic var savedBeerIds: [String] {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: "savedBeerIds") as? [String] ?? [String]()
    }

    func isFavourite(id: String) -> Bool {
        let defaults = UserDefaults.standard
        let beerIds = defaults.object(forKey: "savedBeerIds") as? [String] ?? [String]()
        if let _ = beerIds.firstIndex(of: id) {
            return true
        }
        return false
    }

    func removeElement(id: String) {
        let defaults = UserDefaults.standard
        var beerIds = defaults.object(forKey: "savedBeerIds") as? [String] ?? [String]()
        beerIds.removeAll(where: { $0 == id })
        defaults.set(beerIds, forKey: "savedBeerI	ds")
    }

    func addElement(id: String) {
        let defaults = UserDefaults.standard
        var beerIds = defaults.object(forKey: "savedBeerIds") as? [String] ?? [String]()
        beerIds.append(id)
        defaults.set(beerIds, forKey: "savedBeerIds")
    }
}

