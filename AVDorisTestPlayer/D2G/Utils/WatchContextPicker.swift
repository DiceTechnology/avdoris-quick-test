//
//  WatchContextPicker.swift
//  AVDorisTestPlayer
//
//  Created by Yaroslav Lvov on 09.08.2024.
//  Copyright © 2024 Endeavor Streaming. All rights reserved.
//

import UIKit
import AVDoris

class WatchContextPicker: BaseView {
    var watchContext: WatchContext? {
        var type: WatchContext.ContextType?
        if !playlistRadioButton.isEnabled { type = .playlist }
        if !watchlistRadioButton.isEnabled { type = .watchlist(ownerExternalId: watchListOwnerIdTextField.text ?? "") }
        if !seasonRadioButton.isEnabled { type = .season }
        
        if let type, watchContextToggle.isOn {
            return WatchContext(type: type, id: watchContextIdTextField.text ?? "")
        } else {
            return nil
        }
    }
    
    lazy var watchContextToggleTitle: UILabel = {
        let label = UILabel()
        label.text = "WatchContext"
        return label
    }()
    
    lazy var watchContextToggle: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = false
        toggle.addAction(for: .valueChanged) { [unowned self] in
            buttonsStack.isHidden = !toggle.isOn
        }
        return toggle
    }()
    
    lazy var watchContextToggleStack: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [watchContextToggleTitle,
                                                watchContextToggle])
        sv.isHidden = false
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.spacing = 5
        return sv
    }()
    
    
    lazy var buttonsStack: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [playlistRadioButton,
                                                seasonRadioButton,
                                                watchlistRadioButton,
                                                watchContextIdTextField,
                                                watchListOwnerIdTextField])
        sv.isHidden = true
        sv.axis = .vertical
        sv.distribution = .fillEqually
        sv.spacing = 5
        return sv
    }()
    
    lazy var mainStack: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [watchContextToggleStack,
                                                buttonsStack])
        sv.axis = .vertical
        sv.distribution = .fillProportionally
        return sv
    }()
    
    lazy var watchContextIdTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Id"
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    lazy var watchListOwnerIdTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.isHidden = true
        tf.placeholder = "Owner Id"
        return tf
    }()
    
    lazy var playlistRadioButton: UIButton = {
        let button = UIButton()
        button.setTitle("playlist", for: .normal)
        button.setTitleColor(.blue, for: .disabled)
        button.setTitleColor(.gray, for: .normal)
        button.isEnabled = false
        button.addAction(for: .touchUpInside) { [unowned self] in
            watchlistRadioButton.isEnabled = true
            seasonRadioButton.isEnabled = true
            button.isEnabled = false
            watchListOwnerIdTextField.isHidden = true
        }
        return button
    }()
    
    lazy var watchlistRadioButton: UIButton = {
        let button = UIButton()
        button.setTitle("watchlist", for: .normal)
        button.setTitleColor(.blue, for: .disabled)
        button.setTitleColor(.gray, for: .normal)
        button.isEnabled = true
        button.addAction(for: .touchUpInside) { [unowned self] in
            playlistRadioButton.isEnabled = true
            seasonRadioButton.isEnabled = true
            button.isEnabled = false
            watchListOwnerIdTextField.isHidden = false
        }
        return button
    }()
    
    lazy var seasonRadioButton: UIButton = {
        let button = UIButton()
        button.setTitle("season", for: .normal)
        button.setTitleColor(.blue, for: .disabled)
        button.setTitleColor(.gray, for: .normal)
        button.isEnabled = true
        button.addAction(for: .touchUpInside) { [unowned self] in
            playlistRadioButton.isEnabled = true
            watchlistRadioButton.isEnabled = true
            watchListOwnerIdTextField.isHidden = true
            button.isEnabled = false
        }
        return button
    }()
    
    override func addSubviews() {
        addSubviews([mainStack])
    }
    
    override func anchorSubviews() {
        mainStack.fillSuperview()
    }
}
