//
//  TabBarController.swift
//  dice-shield-ios-example
//
//  Created by mac on 07.04.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    func setup() {
        let firstViewController = PlaybackViewController()
        firstViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 0)
        
        let secondViewController = DownloadsViewController()
        secondViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .downloads, tag: 1)

        let tabBarList = [firstViewController, secondViewController]

        viewControllers = tabBarList
    }
}
