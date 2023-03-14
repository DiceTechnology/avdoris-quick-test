
//
//  BaseTableViewCell.swift
//  elta-ios
//
//  Created by y.lvov on 1/31/19.
//  Copyright © 2020 Endeavor Streaming. All rights reserved.
//

import UIKit

class BaseTableViewCell<View: UIView>: UITableViewCell {
  var mainView: View
 
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    self.mainView = View()
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(mainView)
    mainView.fillSuperview()
  }
 
  @available (*, unavailable) required init?(coder aDecoder: NSCoder) {
    fatalError("required init not implemented")
  }
}
