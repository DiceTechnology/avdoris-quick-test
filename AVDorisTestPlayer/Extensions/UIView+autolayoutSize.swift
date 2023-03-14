//
//  UIView+autolayoutSize.swift
//  raptor_sw_ios
//
//  Created by Yaroslav lvov on 10/18/19.
//  Copyright © 2020 Endeavor Streaming. All rights reserved.
//

import UIKit

extension UIView {
  func autoLayoutSize(withFixedWidth width: CGFloat) -> CGSize {
    return self.systemLayoutSizeFitting(CGSize(width: width,
                                               height: UIView.layoutFittingExpandedSize.height),
                                        withHorizontalFittingPriority: .required,
                                        verticalFittingPriority: .fittingSizeLevel)
  }
  
  func autoLayoutSize(withFixedHeight height: CGFloat) -> CGSize {
    return self.systemLayoutSizeFitting(CGSize(width: UIView.layoutFittingExpandedSize.width,
                                               height: height),
                                        withHorizontalFittingPriority: .fittingSizeLevel,
                                        verticalFittingPriority: .required)
  }
}
