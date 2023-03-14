//
//  ScrollableView.swift
//  dice-shield-ios-example
//
//  Created by mac on 14.04.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class ScrollableView<T: UIView>: BaseView {
  private let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.bounces = true
    if #available(iOS 11.0, *) {
        scrollView.contentInsetAdjustmentBehavior = .always
    }
    return scrollView
  }()
  
  var contentView: T
  
  init(contentView: T) {
    self.contentView = contentView
    super.init(frame: .zero)
  }
  
  @available(*, unavailable) override func addSubviews() {
    scrollView
      .addSubviews([contentView])
    
    addSubviews([scrollView])
  }
  
  @available(*, unavailable) override func anchorSubviews() {
    scrollView
      .fillSuperview()
    
    contentView
      .anchorEqualWidth(scrollView.widthAnchor)
      .anchorEqualHeight(scrollView.heightAnchor, priority: .defaultLow)
      .fillSuperview()
  }
}
