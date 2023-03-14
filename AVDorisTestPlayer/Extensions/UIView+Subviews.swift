//
//  UIView+Subviews.swift
//  elta-ios
//
//  Created by Aleksey Zgurskiy on 2/14/19.
//  Copyright © 2020 Endeavor Streaming. All rights reserved.
//

import UIKit

extension UIView {
  func addSubviews(_ subviews: [UIView]) {
    subviews.forEach { addSubview($0) }
  }
}

extension UIStackView {
  func addArrangedSubviews(_ subviews: [UIView]) {
    subviews.forEach { addArrangedSubview($0) }
  }
}
