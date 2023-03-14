//
//  UIControl+closure.swift
//  elta-ios
//
//  Created by y.lvov on 1/18/19.
//  Copyright © 2020 Endeavor Streaming. All rights reserved.
//

import UIKit

private class ClosureSleeve {
  let closure: (() -> Void)?
  
  init (_ closure: (() -> Void)?) {
    self.closure = closure
  }
  
  @objc func invoke () {
    closure?()
  }
}

extension UIControl {
  @objc func addAction(for controlEvent: UIControl.Event, action: (() -> Void)?) {
    let sleeve = ClosureSleeve(action)
    addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvent)
    objc_setAssociatedObject(self, String(format: "[%d]", arc4random()), sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
  }
}
