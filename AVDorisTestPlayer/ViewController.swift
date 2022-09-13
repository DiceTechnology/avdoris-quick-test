//
//  ViewController.swift
//  AVDorisTestPlayer
//
//  Created by Gabor Balogh on 10/09/2020.
//  Copyright © 2020 Endeavor Streaming. All rights reserved.
//

import AVDoris
import AVKit
import UIKit

class ViewController: UIViewController {
    lazy var buttonVod: UIButton = {
        let button = UIButton()
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
        button.setTitle("Play VOD with server-side ads", for: .normal)
        let action = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.present(CustomPlayerViewController(.daiVodSource), animated: true)        }
        button.addAction(action, for: .touchUpInside)
        return button
    }()
    
    lazy var buttonLiveDAI: UIButton = {
        let button = UIButton()
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
        button.setTitle("Play LIVE with client-side ads", for: .normal)
        let action = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.present(CustomPlayerViewController(.csaiLiveStream), animated: true)
        }
        button.addAction(action, for: .touchUpInside)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.addSubview(stackView)
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
