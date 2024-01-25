//
//  DicePlaybackViewController.swift
//  AVDorisTestPlayer
//
//  Created by Yaroslav Lvov on 23.03.2023.
//  Copyright © 2023 Endeavor Streaming. All rights reserved.
//

import UIKit
import AVDoris

class DicePlaybackViewController: UIViewController {
    var sourceResolver: DorisSourceResolverProtocol?
    
    let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.hidesWhenStopped = true
        return spinner
    }()

    let usernameTextFiled: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.placeholder = "Email"
        return tf
    }()
    
    let passwordTextFiled: UITextField = {
        let tf = UITextField()
        tf.isSecureTextEntry = true
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.placeholder = "Password"
        return tf
    }()
    
    let videoIDTextFiled: UITextField = {
        let tf = UITextField()
        tf.keyboardType = .decimalPad
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.placeholder = "Video id"
        return tf
    }()
    
    let realmTextFiled: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.placeholder = "Realm"
        return tf
    }()
    
    let apiKeyTextFiled: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.placeholder = "API key"
        return tf
    }()
    
    let isLiveLabel: UILabel = {
        let label = UILabel()
        label.text = "VOD(off) / LIVE(on)"
        return label
    }()
    
    let isLiveSwitch: UISwitch = {
        let isLiveSwitch = UISwitch()
        return isLiveSwitch
    }()
    
    lazy var buttonPlay: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Play Dice Video", for: .normal)
        button.backgroundColor = .green
        let action = UIAction { [weak self] _ in
            guard let self = self else { return }

            /// Use `DiceSourceResolver` if you already have auth tokens (in doris consumer app)
//            self.sourceResolver = DiceSourceResolver(videoId: self.videoIDTextFiled.text ?? "",
//                                                     isLive: self.isLiveSwitch.isOn,
//                                                     authToken: "<auth token>",
//                                                     apiConfig: DiceAPIConfig(realm: self.realmTextFiled.text ?? "",
//                                                                              apiKey: self.apiKeyTextFiled.text ?? ""))
                               
            /// Use `DiceSourceResolver` for testing as it maked login request before stream request
            self.sourceResolver = DiceSourceResolver(apiConfig: DiceAPIConfig(realm: self.realmTextFiled.text ?? "",
                                                                                   environment: .staging,
                                                                              apiKey: self.apiKeyTextFiled.text ?? ""))
                                                    .set(authType: .credentials(userName:  self.usernameTextFiled.text ?? "", password: self.passwordTextFiled.text ?? ""))
                                                    .set(videoId: self.videoIDTextFiled.text ?? "", isLive: self.isLiveSwitch.isOn)

            self.spinner.startAnimating()
            self.sourceResolver?.resolveSource() { result in
                self.spinner.stopAnimating()
                switch result {
                case .success(let source):
                    self.present(CustomPlayerViewController(.diceVideo(source: source)), animated: true)
                case .failure(let error):
                    print(error)
                }
            }
        }
        button.addAction(action, for: .touchUpInside)
        return button
    }()
    
    lazy var isLiveStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.addArrangedSubview(isLiveLabel)
        stackView.addArrangedSubview(isLiveSwitch)
        return stackView
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.addArrangedSubview(usernameTextFiled)
        stackView.addArrangedSubview(passwordTextFiled)
        stackView.addArrangedSubview(apiKeyTextFiled)
        stackView.addArrangedSubview(realmTextFiled)
        stackView.addArrangedSubview(videoIDTextFiled)
        stackView.addArrangedSubview(isLiveStackView)
        stackView.addArrangedSubview(buttonPlay)
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupLayout()
        view.backgroundColor = .white
    }
    
    func setupLayout() {
        view.addSubview(stackView)
        view.addSubview(spinner)
        
        stackView
            .anchorTop(view.safeAreaLayoutGuideAnyIOS.topAnchor, 20)
            .anchorLeft(view.leftAnchor, 20)
            .anchorRight(view.rightAnchor, 20)
        
        spinner.anchorCenterSuperview()
    }
}
