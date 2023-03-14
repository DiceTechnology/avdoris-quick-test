//
//  LoadingOverlay.swift
//  SDLockerApp
//
//  Created by Patryk Domagala on 13/04/16.
//  Copyright © 2020 Endeavor Streaming. All rights reserved.
//

import Foundation
import UIKit

open class LoadingOverlay {
    var overlayView : UIView!
    var activityIndicator : UIActivityIndicatorView!
    
    class var shared: LoadingOverlay {
        struct Static {
            static let instance: LoadingOverlay = LoadingOverlay()
        }
        return Static.instance
    }
    
    init() {
        self.overlayView = UIView()
        self.activityIndicator = UIActivityIndicatorView()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.alpha = 0.7
        overlayView.addSubview(blurView)
        
        overlayView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        //        overlayView.backgroundColor = UIColor(white: 0, alpha: 0.7)
        overlayView.clipsToBounds = true
        overlayView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.center = CGPoint(x: overlayView.bounds.width / 2.0, y: overlayView.bounds.height / 2.0)
        activityIndicator.style = .whiteLarge
        overlayView.addSubview(activityIndicator)
    }
    
    open func showOverlay(_ view: UIView, xOffset: Double = 0.0, yOffset: Double = 0.0) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        overlayView.center = CGPoint(x: view.center.x + CGFloat(xOffset), y: view.center.y + CGFloat(yOffset))
        //        overlayView.frame = view.bounds
        
        view.addSubview(overlayView)
        activityIndicator.startAnimating()
    }
    
    open func hideOverlayView() {
        UIApplication.shared.endIgnoringInteractionEvents()
        activityIndicator.stopAnimating()
        overlayView.removeFromSuperview()
    }
}
