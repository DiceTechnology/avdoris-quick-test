//
//  BaseInteractiveView.swift
//  elta-ios
//
//  Created by y.lvov on 1/8/19.
//  Copyright © 2020 Endeavor Streaming. All rights reserved.
//

import UIKit

class BaseView: UIView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    addSubviews()
    anchorSubviews()
  }
  
  @available(*, unavailable) required init?(coder aDecoder: NSCoder) {
    fatalError("required init not implemented")
  }
  
  //to override
  func addSubviews() {}
  func anchorSubviews() {}
}
