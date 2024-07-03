//
//  AppDelegate.swift
//  AVDorisTestPlayer
//
//  Created by Gabor Balogh on 10/09/2020.
//  Copyright © 2020 Endeavor Streaming. All rights reserved.
//

import UIKit
import AVKit
import GoogleCast
import dice_shield_ios

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        setupChromecast()

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = TabBarController()
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func setupChromecast() {
        let criteria = GCKDiscoveryCriteria(applicationID: DorisCastManager.kReceiverAppID)
        let options = GCKCastOptions(discoveryCriteria: criteria)
        GCKCastContext.setSharedInstanceWith(options)
        GCKCastContext.sharedInstance().sessionManager.add(self)
        GCKLogger.sharedInstance().delegate = self
    }
}

extension AppDelegate: GCKLoggerDelegate, GCKSessionManagerListener {
  func logMessage(_ message: String,
                  at _: GCKLoggerLevel,
                  fromFunction function: String,
                  location: String) {
      print("Cast \(location): \(function) - \(message)")
  }
}
