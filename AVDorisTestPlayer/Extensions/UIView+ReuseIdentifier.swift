//
//  ReusableView.swift
//  elta-ios
//
//  Created by y.lvov on 1/30/19.
//  Copyright © 2019 nullgr. All rights reserved.
//

import UIKit


protocol ReusableView: class {
  static var defaultReuseIdentifier: String { get }
}


extension ReusableView where Self: UIView {
  static var defaultReuseIdentifier: String {
    return String(describing: self)
  }
}
