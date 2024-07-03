//
//  CustomPlayerViewController.swift
//  AVDorisTestPlayer
//
//  Created by Yaroslav Lvov on 09.09.2022.
//  Copyright © 2022 Endeavor Streaming. All rights reserved.
//3

import AVDoris
import AVKit

enum PlaybackItemType {
    case simpleVODSource
    case simpleLiveSource
    case daiVodSource
    case daiLiveSource
    case csaiVodStream
    case csaiLiveStream
    case diceVideo(source: DorisResolvableSource)
    case downloadedSource(filePath: URL)
}

class CustomAVPlayerViewController: AVPlayerViewController, AVPictureInPictureControllerDelegate {
    lazy var adsOverlayView: UIView = {
        let adsOverlayView = UIView()
        adsOverlayView.isHidden = true // hide initially and manage isHidden based on AdvertisementEvent.AD_BREAK_ENDED, AdvertisementEvent.AD_BREAK_STARTED
        return adsOverlayView
    }()
    
    var isPipActive = false
    var doris: DorisPlayer?
    var playbackItemType: PlaybackItemType
    let contentPlayer = AVPlayer()

    init(_ type: PlaybackItemType) {
        playbackItemType = type
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overCurrentContext
        addObserver(self, forKeyPath: #keyPath(AVPlayerViewController.videoBounds), options: [.old, .new], context: nil)
    }
    
    public override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayerViewController.videoBounds),
           let new = change?[.newKey] as? CGRect,
           let old = change?[.oldKey] as? CGRect,
           new != old {
            adsOverlayView.frame = new
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        removeObserver(self, forKeyPath: #keyPath(AVPlayerViewController.videoBounds))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //use view did appear cause ads might fail to load if you load stream with ads in viewDidLoad(_:)
        loadSource(for: playbackItemType)
    }
    
    func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        contentOverlayView?.addSubview(adsOverlayView)
        
        self.player = contentPlayer
        //this config is used to configure UI container for ADS, in case of custom UI provide you own view for ads
        let adsConfig = DorisAdsConfig(adContainerVC: self, adContainerView: adsOverlayView)
        
        let config = AVDorisConfig(uiType: .native(playerViewController: self),
                                   playerConfig: .default,
                                   adsConfig: adsConfig)
        
        doris = AVDorisFactory.create(player: contentPlayer, config: config, output: self)
        //Configure logger if needed
        DorisLogger.logFilter = [.info, .warning, .error, .critical, .state] //[.debug, .events]
        
        //set DorisPlayerMediaMetadata (NowPlayingInfo - lock screen controls)
        let metadata = DorisPlayerMediaMetadata(title: "Title", artist: "Artist", albumTitle: "album", image: nil, remoteImageUrl: URL(string: "https://via.placeholder.com/300x200"))
        doris?.updateMetadata(metadata)
        
        //make sure you set this to avoid system override DorisPlayerMediaMetadata
        updatesNowPlayingInfoCenter = false
    }
    
    func loadSource(for playbackItemType: PlaybackItemType) {
        switch playbackItemType {
        case .simpleVODSource:
            loadSimpleVODSource()
        case .simpleLiveSource:
            loadSimpleLiveSource()
        case .daiVodSource:
            loadDAIVodSource()
        case .daiLiveSource:
            loadDAILiveSource()
        case .csaiVodStream:
            loadCSAIVodStream()
        case .csaiLiveStream:
            loadCSAILiveStream()
        case .downloadedSource(let filePath):
            loadDownloadedContent(filePath: filePath)
        case .diceVideo(let source):
            doris?.load(resolvable: source, initialSeek: nil, delay: nil, autoStart: true, completion: {_ in})
        }
    }
    
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        isPipActive = true
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        isPipActive = false
    }
    
    @objc func didEnterBackground() {
        //avoid player pausing when backgrounded
        guard !isPipActive else { return }
        self.player = nil
    }
    
    @objc func willEnterForeground() {
        self.player = contentPlayer
    }
    
    private func loadSimpleVODSource(startAt: Double? = nil) {
        var initialSeek: DorisSeekType?
        if let startAt = startAt {
            initialSeek = .position(startAt, isAccurate: false)
        }
        let source = DorisSource(type: .item(AVPlayerItem(url: URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!)))
        doris?.load(source: source, initialSeek: initialSeek, delay: nil, autoStart: true)
    }
    
    private func loadSimpleLiveSource(startAt: Double? = nil) {
        var initialSeek: DorisSeekType?
        if let startAt = startAt {
            initialSeek = .position(startAt, isAccurate: false)
        }
        let source = DorisSource(type: .item(AVPlayerItem(url: URL(string: "https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8")!)))
        doris?.load(source: source, initialSeek: initialSeek, delay: nil, autoStart: true)
    }
        
    private func loadDAIVodSource() {
        let contentSourceID = "2528370"
        let videoID = "tears-of-steel"
        let source = DorisSource(type: .ssai(.ima(.vod(DorisImaVODData(contentSourceId: contentSourceID, videoId: videoID, authToken: nil, adTagParameters: nil)))))
        doris?.load(source: source, initialSeek: nil, delay: nil, autoStart: true)
    }
    
    private func loadDAILiveSource() {
        let assetKey = "sN_IYUG8STe1ZzhIIE_ksA"
        let source = DorisSource(type: .ssai(.ima(.live(DorisImaLiveData(assetKey: assetKey, authToken: nil, adTagParameters: nil, adTagParametersValidFrom: nil, adTagParametersValidUntil: nil)))))
        doris?.load(source: source, initialSeek: nil, delay: nil, autoStart: true)
    }
    
    private func loadCSAIVodStream() {
        let vmap = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/ad_rule_samples&ciu_szs=300x250&ad_rule=1&impl=s&gdfp_req=1&env=vp&output=vmap&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ar%3Dpreonly&cmsid=496&vid=short_onecue&correlator="

        let contentURL = URL(string: "https://storage.googleapis.com/gvabox/media/samples/stock.mp4")!
        let source = DorisSource(type: .csai(.ima(.vod(contentURL, adUrl: vmap))))
        doris?.load(source: source, initialSeek: nil, delay: nil, autoStart: true)
    }
    
    private func loadCSAILiveStream() {
        //only prerolls supported for now
        let adsURL = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/ad_rule_samples&ciu_szs=300x250&ad_rule=1&impl=s&gdfp_req=1&env=vp&output=vmap&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ar%3Dpreonly&cmsid=496&vid=short_onecue&correlator="
        
        let contentURL = URL(string: "https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8")!
        let source = DorisSource(type: .csai(.ima(.live(contentURL, prerollUrl: adsURL))))
        doris?.load(source: source, initialSeek: nil, delay: nil, autoStart: true)
    }
    
    private func loadDownloadedContent(filePath: URL) {
        let metadata = DorisSourceMetadata(videoId: "1", isLive: false, url: filePath.absoluteURL)
        metadata.drm = DorisDRMSource(contentUrl: filePath.absoluteString,
                                      croToken: nil,
                                      licensingServerUrl: nil)
        let source = DorisSource(type: .item(AVPlayerItem(url: filePath)), metadata: metadata)
        doris?.load(source: source, initialSeek: nil, delay: nil, autoStart: true)
    }
}


extension CustomAVPlayerViewController: DorisPlayerOutputProtocol, SystemOutputProtocol {
    func onPlayerStateChanged(old: DorisPlayerState, new: DorisPlayerState) {
        //
    }
    
    func onPlayerEvent(_ event: DorisPlayerEvent) {
        switch event {
        case .streamTypeRecognized(streamType: let streamType):
            switch streamType {
            case .LIVE:
                var config = DorisRemoteCommandsConfig()
                config.isPlayEnabled = true
                config.isPauseEnabled = true
                config.isPlayPauseEnabled = true
                config.isSkipBackwardEnabled = true
                config.isSkipForwardEnabled = true
                config.isChangePositionEnabled = false
                doris?.updateRemoteCommands(with: config)
            case .VOD:
                doris?.updateRemoteCommands(with: .default)
            default: break
            }
        default: break
        }
    }
    
    func onAdvertisementEvent(_ event: DorisAdsEvent) {
        switch event {
        case .adBreakEnded:
            adsOverlayView.isHidden = true
            showsPlaybackControls = true
        case .adBreakStarted:
            adsOverlayView.isHidden = false
            showsPlaybackControls = false
        default: break
        }
    }
    
    func onRemoteCommandEvent(_ event: DorisRemoteCommandEvent) {
        switch event {
        case .play:
            doris?.play()
        case .pause:
            doris?.pause()
        case .skipBackward(let offset):
            doris?.seek(.offset(-offset, isAccurate: false), callback: nil)
        case .skipForward(let offset):
            doris?.seek(.offset(offset, isAccurate: false), callback: nil)
        case .changePosition(let position):
            doris?.seek(.position(position, isAccurate: false), callback: nil)
        default: break
        }
    }
    
    func onSystemEvent(_ event: DorisSystemEvent) {
        //
    }
}
