//
//  MainTabBarController.swift
//  FoamyCool
//
//  Created by Kyrylo Danylov on 9/21/19.
//  Copyright © 2019 Kyrylo Danylov. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let searchVC = SearchVC()
        let locationVC = LocationVC()
        let favouriteVC = FavouriteVC()
        
        searchVC.tabBarItem = UITabBarItem(title: "Search", image: UIImage(named: "search"), tag: 0)
        locationVC.tabBarItem = UITabBarItem(title: "Location", image: UIImage(named: "location"), tag: 1)
        favouriteVC.tabBarItem = UITabBarItem(title: "Favourite", image: UIImage(named: "favourite"), tag: 2)
        
        let tabBarList = [searchVC, locationVC, favouriteVC]
        viewControllers = tabBarList
    }
}
