//
//  DicePlaybackViewController.swift
//  AVDorisTestPlayer
//
//  Created by Yaroslav Lvov on 23.03.2023.
//  Copyright © 2023 Endeavor Streaming. All rights reserved.
//

import UIKit
import VesperSDK
import AVDoris


class DicePlaybackViewController: UIViewController {
    let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    lazy var pickerView: UIPickerView = {
        let pv = UIPickerView()
        pv.delegate = self
        pv.dataSource = self
        return pv
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
    
    let isLiveLabel: UILabel = {
        let label = UILabel()
        label.text = "isLive"
        return label
    }()
    
    let isLiveSwitch: UISwitch = {
        let isLiveSwitch = UISwitch()
        return isLiveSwitch
    }()
    
    let watchContextPicker: WatchContextPicker = {
        let picker = WatchContextPicker()
        return picker
    }()
    
    lazy var buttonPlay: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Load", for: .normal)
        button.backgroundColor = .systemBlue
        let action = UIAction { [weak self] _ in
            guard let self = self else { return }
            let vc = VesperPlayerViewController(apiConfig: APIConfig(realm: realmTextFiled.text ?? "",
                                                                     environment: APIConfig.Environment.allCases[pickerView.selectedRow(inComponent: 0)],
                                                                     apiKey: "9ae946e6-3374-485f-9737-662cae419fef"),
                                                username: usernameTextFiled.text ?? "",
                                                password: passwordTextFiled.text ?? "",
                                                source: ResolvableSource(id: videoIDTextFiled.text ?? "",
                                                                         isLive: isLiveSwitch.isOn,
                                                                         watchContext: watchContextPicker.watchContext))
            
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
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
        stackView.addArrangedSubview(realmTextFiled)
        stackView.addArrangedSubview(videoIDTextFiled)
        stackView.addArrangedSubview(isLiveStackView)
        stackView.addArrangedSubview(watchContextPicker)
        stackView.addArrangedSubview(buttonPlay)
        stackView.addArrangedSubview(pickerView)
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


extension DicePlaybackViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return APIConfig.Environment.allCases.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return APIConfig.Environment.allCases[row].rawValue
    }
}
