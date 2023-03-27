//
//  DemoPlaybackViewController.swift
//  AVDorisTestPlayer
//
//  Created by Gabor Balogh on 10/09/2020.
//  Copyright © 2020 Endeavor Streaming. All rights reserved.
//

import AVDoris
import AVKit
import UIKit
import GoogleCast

class DemoPlaybackViewController: UIViewController {
    lazy var buttonVod: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Play VOD", for: .normal)
        let action = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.present(CustomPlayerViewController(.simleVODSource), animated: true)
        }
        button.addAction(action, for: .touchUpInside)
        return button
    }()
    
    lazy var buttonLive: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Play LIVE", for: .normal)
        let action = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.present(CustomPlayerViewController(.simleLiveSource), animated: true)
        }
        button.addAction(action, for: .touchUpInside)
        return button
    }()
    
    lazy var buttonVodDAI: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Play VOD with server-side ads", for: .normal)
        let action = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.present(CustomPlayerViewController(.daiVodSource), animated: true)        }
        button.addAction(action, for: .touchUpInside)
        return button
    }()
    
    lazy var buttonLiveDAI: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Play LIVE with server-side ads", for: .normal)
        let action = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.present(CustomPlayerViewController(.daiLiveSource), animated: true)
        }
        button.addAction(action, for: .touchUpInside)
        return button
    }()
    
    lazy var buttonVodCSAI: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Play VOD with client-side ads", for: .normal)
        let action = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.present(CustomPlayerViewController(.csaiVodStream), animated: true)
        }
        button.addAction(action, for: .touchUpInside)
        return button
    }()
    
    lazy var buttonLiveCSAI: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Play LIVE with client-side ads", for: .normal)
        let action = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.present(CustomPlayerViewController(.csaiLiveStream), animated: true)
        }
        button.addAction(action, for: .touchUpInside)
        return button
    }()
    
    lazy var buttonCast: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Cast test video", for: .normal)
        button.setTitle("Connect to CC to cast", for: .disabled)
        button.setTitleColor(.gray, for: .disabled)
        button.setTitleColor(.black, for: .normal)
        button.isEnabled = false
        let action = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.testCast()
        }
        button.addAction(action, for: .touchUpInside)
        return button
    }()
    
    let chromecastConnectButton: GCKUICastButton = {
        let button = GCKUICastButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .black
        return button
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(buttonVod)
        stackView.addArrangedSubview(buttonLive)
        stackView.addArrangedSubview(buttonVodDAI)
        stackView.addArrangedSubview(buttonLiveDAI)
        stackView.addArrangedSubview(buttonVodCSAI)
        stackView.addArrangedSubview(buttonLiveCSAI)
        return stackView
    }()
    
    let castManager = DorisCastManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        castManager.delegate = self
        view.backgroundColor = .white
    }
    
    func setupLayout() {
        view.addSubview(chromecastConnectButton)
        view.addSubview(buttonCast)
        view.addSubview(stackView)
        
        chromecastConnectButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        chromecastConnectButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        chromecastConnectButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        chromecastConnectButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        buttonCast.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        buttonCast.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
                
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
        
    private func testCast() {
        castManager.cast()
    }
}

extension DemoPlaybackViewController: DorisCastManagerDelegate {
    func castStateDidChange(isConnected: Bool) {
        buttonCast.isEnabled = isConnected
    }
}

