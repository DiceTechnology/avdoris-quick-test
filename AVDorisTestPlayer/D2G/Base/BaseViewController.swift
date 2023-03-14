//
//  EventsEntity.swift
//  SampleApp
//
//  Created by mac on 04.08.2019.
//  Copyright © 2019 Yaroslav Lvov. All rights reserved.
//

import UIKit

class BaseViewController<View: UIView>: UIViewController {
  var mainView: View
  private var wasShownAtLeastOnce = false
  
  init(view: View) {
    self.mainView = view
    super.init(nibName: nil, bundle: nil)
  }
  
  @available (*, unavailable) required init?(
    coder aDecoder: NSCoder) {
    fatalError("required init not implemented")
  }
  
  //MARK: ViewController lifecycle
  override func loadView() {
    view = mainView
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if wasShownAtLeastOnce {
      viewWillAppearAgain()
    } else {
      viewWillAppearAtFirstTime()
    }
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    if wasShownAtLeastOnce {
      viewWillLayoutSubviewsAgain()
    } else {
      viewWillLayoutSubviewsAtFirstTime()
    }
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    if wasShownAtLeastOnce {
      viewDidLayoutSubviewsAgain()
    } else {
      viewDidLayoutSubviewsAtFirstTime()
    }
  }
    
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if wasShownAtLeastOnce {
      viewDidAppearAgain()
    } else {
      viewDidAppearAtFirstTime()
    }
    
    wasShownAtLeastOnce = true
  }
  
  
  
  func viewWillAppearAtFirstTime() {
    //to override
  }
  
  func viewWillAppearAgain() {
    //to override
  }
  
  func viewWillLayoutSubviewsAtFirstTime() {
    //to override
  }
  
  func viewWillLayoutSubviewsAgain() {
    //to override
  }
  
  func viewDidLayoutSubviewsAtFirstTime() {
    //to override
  }
  
  func viewDidLayoutSubviewsAgain() {
    //to override
  }
  
  func viewDidAppearAtFirstTime() {
    //to override
  }
  
  func viewDidAppearAgain() {
    //to override
  }
}
