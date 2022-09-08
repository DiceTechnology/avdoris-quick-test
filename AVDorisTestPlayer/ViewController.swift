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
    var doris: DorisPlayer?
    var playerController = AVPlayerViewController()
    
    lazy var buttonVod: UIButton = {
        let button = UIButton()
        button.setTitle("Play VOD", for: .normal)
        let action = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.present(self.playerController, animated: true) {
                self.loadSimpleVODSource()
                print("zzz loaded VOD 1")
                DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                    print("zzz loaded VOD 2")
                    self.loadSimpleVODSource(startAt: 100)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
                    print("zzz loaded VOD 3")
                    self.loadSimpleVODSource(startAt: 300)
                }
            }
        }
        button.addAction(action, for: .touchUpInside)
        return button
    }()
    
    lazy var buttonLive: UIButton = {
        let button = UIButton()
        button.setTitle("Play LIVE", for: .normal)
        let action = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.present(self.playerController, animated: true) {
                self.loadSimpleLiveSource(startAt: 20)
            }
        }
        button.addAction(action, for: .touchUpInside)
        return button
    }()
    
    lazy var buttonVodDAI: UIButton = {
        let button = UIButton()
        button.setTitle("Play VOD with server-side ads", for: .normal)
        let action = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.present(self.playerController, animated: true) {
                self.loadDAIVodSource()
            }
        }
        button.addAction(action, for: .touchUpInside)
        return button
    }()
    
    lazy var buttonLiveDAI: UIButton = {
        let button = UIButton()
        button.setTitle("Play LIVE with server-side ads", for: .normal)
        let action = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.present(self.playerController, animated: true) {
                self.loadDAILiveSource()
            }
        }
        button.addAction(action, for: .touchUpInside)
        return button
    }()
    
    lazy var buttonVodCSAI: UIButton = {
        let button = UIButton()
        button.setTitle("Play VOD with client-side ads", for: .normal)
        let action = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.present(self.playerController, animated: true) {
                self.loadCSAIVodStream()
            }
        }
        button.addAction(action, for: .touchUpInside)
        return button
    }()
    
    lazy var buttonLiveCSAI: UIButton = {
        let button = UIButton()
        button.setTitle("Play LIVE with client-side ads", for: .normal)
        let action = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.present(self.playerController, animated: true) {
                self.loadCSALiveStream()
            }
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
        
        if doris == nil {
            setupAVDorisWithNativeUI()
            
            view.addSubview(stackView)
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        }
    }
    
    func setupAVDorisWithNativeUI() {
        let player = AVPlayer()
        
        //provide playerLayer in case you are using custom UI for PIP support otherwise pass nil and control that over playerController.allowsPictureInPicturePlayback = true/false
        let pictureInPictureConfig = DorisPipConfig(playerLayer: nil)
        playerController.allowsPictureInPicturePlayback = true
        playerController.player = player

        //Use doris?.configureMux(playerData: _, videoData: _) to setup mux tracking
        let muxConfig = DorisMuxConfig(muxType: .nativeUI(playerViewController: playerController))
        
        //this config is used to configure UI container for ADS, in case of custom UI provide you own view for ads
        let adsConfig = DorisAdsConfig(adContainerVC: self.playerController, adContainerView: self.playerController.view)
        
        let config = DorisPluginsConfig(pip: pictureInPictureConfig, mux: muxConfig, ads: adsConfig)
        self.doris = AVDorisFactory.create(player: player, pluginsConfig: config, output: self)
        player.allowsExternalPlayback = true
    }
    
    func loadSimpleVODSource(startAt: Double? = nil) {
        let source = PlayerItemSource(playerItem: AVPlayerItem(url: URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!))
        doris?.load(source: source, startAt: startAt)
    }
    
    func loadSimpleLiveSource(startAt: Double? = nil) {
        let source = PlayerItemSource(playerItem: AVPlayerItem(url: URL(string: "https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8")!))
        doris?.load(source: source, startAt: startAt)
    }
        
    func loadDAIVodSource() {
        let contentSourceID = "2528370"
        let videoID = "tears-of-steel"
        let source = DAISource(contentSourceId: contentSourceID,
                               videoId: videoID,
                               authToken: nil,
                               adTagParameters: nil)
        
        doris?.load(source: source)
    }
    
    func loadDAILiveSource() {
        let assetKey = "sN_IYUG8STe1ZzhIIE_ksA"
        let source = DAISource(assetKey: assetKey,
                               authToken: nil,
                               adTagParameters: nil,
                               adTagParametersValidFrom: .distantPast,
                               adTagParametersValidUntil: .distantFuture)
        
        doris?.load(source: source)
    }
    
    func loadCSAIVodStream() {
        let adsURL = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/ad_rule_samples&ciu_szs=300x250&ad_rule=1&impl=s&gdfp_req=1&env=vp&output=vmap&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ar%3Dpreonly&cmsid=496&vid=short_onecue&correlator="
        
        let contentURL = URL(string: "https://storage.googleapis.com/gvabox/media/samples/stock.mp4")!
        let source = CSAISource(contentURL: contentURL, adsURL: adsURL, isLive: false)
        
        doris?.load(source: source)
    }
    
    func loadCSALiveStream() {
        //only prerolls supported for now
        let adsURL = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/ad_rule_samples&ciu_szs=300x250&ad_rule=1&impl=s&gdfp_req=1&env=vp&output=vmap&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ar%3Dpreonly&cmsid=496&vid=short_onecue&correlator="
        
        let contentURL = URL(string: "https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8")!
        let source = CSAISource(contentURL: contentURL, adsURL: adsURL, isLive: false)
        
        doris?.load(source: source)
    }
}

extension ViewController: DorisPlayerOutputProtocol {
    func onPlayerEvent(_ event: DorisPlayerEvent) {
        switch event {
        case .stateChanged(let state):
            print(">>> Current player state", state)
        case .finishedPlaying(let endTime):
            print(">>> Playback finished end time:", endTime)
        case .currentTimeChanged(let time):
            print(">>> Current playback time changed:", time)
        case .itemDurationChanged(let duration):
            print(">>> Current item duration changed:", duration)
        case .seekableTimeRangesChanged(let start, let end):
            print(">>> Seekable timeranges:", start)
            print(">>> Seekable timeranges:", end)
        case .availableMediaSelectionLoaded(let subtitles, let audioTracks):
            print(">>> available subtitles", subtitles)
            print(">>> available audioTracks", audioTracks)
        default: break
        }
    }

    func onAdvertisementEvent(_ event: AdvertisementEvent) {
        switch event {
        case .STREAM_STARTED(let streamStartedData):
            print(">>> Stream with ads started", streamStartedData)
        case .REQUIRE_AD_TAG_PARAMETERS(let requireAdTagParametersData):
            print(">>> Need to update ad tag parameters for live stream", requireAdTagParametersData)
//            doris?.replaceAdTagParameters(adTagParameters: [:], validFrom: nil, validUntil: nil)
        case .AD_RANGES_CHANGED(let adRangesChangedData):
            print(">>> Array of ads ranges for current stream, to place marks on a seek bar to show where the ad starts/ends", adRangesChangedData)
        case .AD_PROGRESS_CHANGED(let adProgressChangedData):
            print(">>> when an ad starts this event is triggered to provide more info about current ad brreak", adProgressChangedData)
        case .AD_BREAK_ENDED:
            print(">>> ad break ended")
        case .AD_BREAK_STARTED:
            print(">>> ad break started")
        case .AD_STARTED(let adStartedData):
            print(">>> single ad within some ad break started", adStartedData)
        case .AD_ENDED(let adEndedData):
            print(">>> single ad within some ad break ended", adEndedData)
        case .AD_PAUSE:
            print(">>> ad paused")
        case .AD_RESUME:
            print(">>> ad resumed")
        default: break
        }
    }

    func onError(_ error: Error) {
        print(error)
    }
}
