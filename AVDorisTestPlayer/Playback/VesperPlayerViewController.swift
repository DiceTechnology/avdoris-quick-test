//
//  VesperPlayerViewController.swift
//  AVDorisTestPlayer
//
//  Created by Yaroslav Lvov on 21.06.2024.
//  Copyright © 2024 Endeavor Streaming. All rights reserved.
//

import VesperSDK
import AVDoris
import GoogleCast

class VesperPlayerViewController: UIViewController {
    var orientation = UIInterfaceOrientationMask.portrait
    
    override var shouldAutorotate: Bool {
        false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return orientation
    }
    
    let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .white
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Close", for: .normal)
        button.tintColor = .systemBlue
        let action = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.dismiss(animated: true)
        }
        button.addAction(action, for: .touchUpInside)
        return button
    }()
    
    var landscapeConstraints: [NSLayoutConstraint] = []
    var portraitConstraints: [NSLayoutConstraint] = []
    
    var vesperSDKManager: VesperSDKManager
    var playerManager: PlayerManager?
    let source: ResolvableSource
    
    init(apiConfig: APIConfig,
         username: String,
         password: String,
         source: ResolvableSource) {    
        let authManager = DebugDiceAuthManager(username: username, password: password, apiConfig: apiConfig)
        let config = VesperSDKConfig(apiConfig: apiConfig, authManager: authManager)
        let vesperSDKManager = VesperSDKManager(config: config)
        self.vesperSDKManager = vesperSDKManager
        self.source = source
        
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = .black
        
        view.addSubview(spinner)
        view.addSubview(closeButton)
        closeButton
            .anchorTop(view.safeAreaLayoutGuideAnyIOS.topAnchor, 20)
            .anchorCenterXToSuperview()
        spinner.anchorCenterSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.startAnimating()
        vesperSDKManager.createPlayerManager(playerOutput: self, userInterfaceConfig: .default(output: nil)) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let playerManager):
                self.playerManager = playerManager
                
                self.playerManager?.uiManager?.viewModel.toggles.isFullscreen = orientation != .portrait
                
                if let uiManager = playerManager.uiManager {
                    self.setupLayout(uiManager: uiManager)
                }
                
                self.sampleLoad(playerManager: playerManager)
            case .failure(let error):
                if let error = error as? VesperSDKError {
                    print("zzz Create PlayerManager error: ", error)
                }
            }
            
            self.spinner.stopAnimating()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        playerManager?.uiManager?.viewModel.toggles.isFullscreen = orientation != .portrait
        self.landscapeConstraints.forEach { $0.isActive = orientation != .portrait }
        self.portraitConstraints.forEach { $0.isActive = orientation == .portrait }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func setupLayout(uiManager: UIManager) {
        view.addSubview(uiManager.viewController.view)
        addChild(uiManager.viewController)
        uiManager.viewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        portraitConstraints = [
            uiManager.viewController.view.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            uiManager.viewController.view.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            uiManager.viewController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
            uiManager.viewController.view.heightAnchor.constraint(equalToConstant: min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * 9/16)
        ]
        
        landscapeConstraints = [
            uiManager.viewController.view.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            uiManager.viewController.view.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            uiManager.viewController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            uiManager.viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ]
        
        portraitConstraints.forEach { $0.isActive = true }
    }
    
    func sampleLoad(playerManager: PlayerManager) {
        playerManager.load(source: source) { error in
            if let error = error as? VesperSDKError {
                //handle load error
            }
        }
    }
}


extension VesperPlayerViewController: DorisViewOutputProtocol, DorisPlayerOutputProtocol {
    func onPlayerEvent(_ event: DorisPlayerEvent) {
        switch event {
        case .playerItemFailed(let logs, let playerError):
            switch playerError {
            case .beacons(let error):
                //handle beacons error
                break
            default: break
            }
        default: break
        }
    }
    func onViewUniversalEvent(_ event: AVDoris.DorisViewUniversalEvent) {}
    func viewDidChangeState(old: AVDoris.DorisViewState, new: AVDoris.DorisViewState) {}
    func onViewTapEvent(_ event: DorisViewTapEvent) {
        switch event {
        case .backButtonTap:
            dismiss(animated: true)
        case .fullScreenButtonTap:
            if playerManager?.uiManager?.viewModel.toggles.isFullscreen == true {
                let value = UIInterfaceOrientation.portrait.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
                playerManager?.uiManager?.viewModel.toggles.isFullscreen = false
                orientation = .portrait
                UIViewController.attemptRotationToDeviceOrientation()
            } else {
                let value = UIInterfaceOrientation.landscapeRight.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
                playerManager?.uiManager?.viewModel.toggles.isFullscreen = true
                orientation = .landscapeRight
                UIViewController.attemptRotationToDeviceOrientation()
            }
        default: break
        }
    }
}
