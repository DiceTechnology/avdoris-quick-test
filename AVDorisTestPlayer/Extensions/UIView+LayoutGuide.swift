//
//  UIView+LayoutGuide.swift
//  raptor_sw_ios
//
//  Created by Yaroslav lvov on 10/4/19.
//  Copyright © 2019 Bkstg. All rights reserved.
//

import UIKit

protocol LayoutGuideProvider {
  var leadingAnchor: NSLayoutXAxisAnchor { get }
  var trailingAnchor: NSLayoutXAxisAnchor { get }
  var leftAnchor: NSLayoutXAxisAnchor { get }
  var rightAnchor: NSLayoutXAxisAnchor { get }
  var topAnchor: NSLayoutYAxisAnchor { get }
  var bottomAnchor: NSLayoutYAxisAnchor { get }
  var widthAnchor: NSLayoutDimension { get }
  var heightAnchor: NSLayoutDimension { get }
  var centerXAnchor: NSLayoutXAxisAnchor { get }
  var centerYAnchor: NSLayoutYAxisAnchor { get }
}

extension UIView: LayoutGuideProvider { }
extension UILayoutGuide: LayoutGuideProvider { }

extension UIView {
  var safeAreaLayoutGuideAnyIOS: LayoutGuideProvider {
    if #available(iOS 11, *) {
      return safeAreaLayoutGuide
    } else {
      return self
    }
  }
  
  var safeAreaInsetsAnyIOS: UIEdgeInsets? {
    if #available(iOS 11, *) {
      return safeAreaInsets
    } else {
      return nil
    }
  }
}
