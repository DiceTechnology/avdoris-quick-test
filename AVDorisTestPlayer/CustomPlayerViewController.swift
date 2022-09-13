//
//  CustomPlayerViewController.swift
//  AVDorisTestPlayer
//
//  Created by Yaroslav Lvov on 09.09.2022.
//  Copyright © 2022 Endeavor Streaming. All rights reserved.
//

import AVDoris
import AVKit

enum PlaybackItemType {
    case simleVODSource
    case simleLiveSource
    case daiVodSource
    case daiLiveSource
    case csaiVodStream
    case csaiLiveStream
}

class CustomPlayerViewController: AVPlayerViewController, AVPictureInPictureControllerDelegate {
    lazy var adsOverlayView: DorisPlayerLayerViewProtocol = {
        let adsOverlayView = DorisPlayerLayerView()
        adsOverlayView.isHidden = true // hide initially and manage isHidden based on AdvertisementEvent.AD_BREAK_ENDED, AdvertisementEvent.AD_BREAK_STARTED
        adsOverlayView.player = AVPlayer() //pass a new, separate instance of AVPlayer that will be responsible for ads playback
        adsOverlayView.frame = UIScreen.main.bounds
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adsOverlayView.frame = contentOverlayView?.bounds ?? .zero
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        doris?.stopMuxMonitoring()
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
        
        
        //MARK: Optional
        //if you use MUX, make sure you call doris?.cleanUpMux() when you are done with playback, to destroy AVplayerViewController instance it is monitoring
        doris?.startMuxMonitoring(playerData: DorisMuxCustomerPlayerData(playerName: "MyPlayer", environmentKey: "key"), videoData: DorisMuxCustomerVideoData())
        
        //set DorisPlayerMediaMetadata (NowPlayingInfo - lock screen controls)
        let metadata = DorisPlayerMediaMetadata(title: "Title", artist: "Artist", albumTitle: "album", image: nil, remoteImageUrl: URL(string: "https://via.placeholder.com/300x200"))
        doris?.updateMetadata(metadata)
        
        //make sure you set this to avoid system override DorisPlayerMediaMetadata
        updatesNowPlayingInfoCenter = false
    }
    
    func loadSource(for playbackItemType: PlaybackItemType) {
        switch playbackItemType {
        case .simleVODSource:
            loadSimpleVODSource()
        case .simleLiveSource:
            loadSimpleLiveSource()
        case .daiVodSource:
            loadDAIVodSource()
        case .daiLiveSource:
            loadDAILiveSource()
        case .csaiVodStream:
            loadCSAIVodStream()
        case .csaiLiveStream:
            loadCSAILiveStream()
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
        let source = PlayerItemSource(playerItem: AVPlayerItem(url: URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!))
        doris?.load(source: source, startAt: startAt)
    }
    
    private func loadSimpleLiveSource(startAt: Double? = nil) {
        let source = PlayerItemSource(playerItem: AVPlayerItem(url: URL(string: "https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8")!))
        doris?.load(source: source, startAt: startAt)
    }
        
    private func loadDAIVodSource() {
        let contentSourceID = "2528370"
        let videoID = "tears-of-steel"
        let source = DAISource(contentSourceId: contentSourceID,
                               videoId: videoID,
                               authToken: nil,
                               adTagParameters: nil)
        
        doris?.load(source: source)
    }
    
    private func loadDAILiveSource() {
        let assetKey = "sN_IYUG8STe1ZzhIIE_ksA"
        let source = DAISource(assetKey: assetKey,
                               authToken: nil,
                               adTagParameters: nil,
                               adTagParametersValidFrom: .distantPast,
                               adTagParametersValidUntil: .distantFuture)
        
        doris?.load(source: source)
    }
    
    private func loadCSAIVodStream() {
        let adsURL = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/ad_rule_samples&ciu_szs=300x250&ad_rule=1&impl=s&gdfp_req=1&env=vp&output=vmap&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ar%3Dpreonly&cmsid=496&vid=short_onecue&correlator="
        
        let contentURL = URL(string: "https://storage.googleapis.com/gvabox/media/samples/stock.mp4")!
        let source = CSAISource(contentURL: contentURL, adsURL: adsURL)
        
        doris?.load(source: source)
    }
    
    private func loadCSAILiveStream() {
        //only prerolls supported for now
        let adsURL = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/ad_rule_samples&ciu_szs=300x250&ad_rule=1&impl=s&gdfp_req=1&env=vp&output=vmap&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ar%3Dpreonly&cmsid=496&vid=short_onecue&correlator="
        
        let contentURL = URL(string: "https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8")!
        let source = CSAISource(contentURL: contentURL, adsURL: adsURL)
        
        doris?.load(source: source)
    }
}


extension CustomPlayerViewController: DorisPlayerOutputProtocol {
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
        case .willLoadAfterDelay(delay: let delay, position: let position):
            print(">>> willLoadAfterDelay", delay, "at postion", position as Any)
        case .willLoadNow:
            print(">>> stream willLoad now")
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
            case .unknown:
                break
            }
            print(">>> stream type", streamType)
        case .loadedTimeRangesChanged(start: let start, end: let end):
            print(">>> loadedTimeRangesChanged", start, end)
        case .audioSessionRouteChanged(route: let route):
            print(">>> audioSessionRouteChanged", route)
        case .playbackLogsUpdated(logs: let logs):
//            print(">>> playback logs", logs)
            break
        case .playbackErrorLogsUpdated(logs: let logs):
            print(">>> error logs", logs)
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
            adsOverlayView.isHidden = true
            showsPlaybackControls = true
            print(">>> ad break ended")
        case .AD_BREAK_STARTED:
            adsOverlayView.isHidden = false
            showsPlaybackControls = false
            print(">>> ad break started")
        case .AD_STARTED(let adStartedData):
            print(">>> single ad within some ad break started", adStartedData)
        case .AD_ENDED(let adEndedData):
            print(">>> single ad within some ad break ended", adEndedData)
        case .AD_PAUSE:
            print(">>> ad paused")
        case .AD_RESUME:
            print(">>> ad resumed")
        case .willSeekWithSnapBack(snapBackPosition: let snapBackPosition, requestedPosition: let requestedPosition):
            print(">>> willSeekWithSnapBack")
        case .didSeekWithSnapBack(snapBackPosition: let snapBackPosition, requestedPosition: let requestedPosition):
            print(">>> didSeekWithSnapBack")
        }
    }
    
    func onRemoteCommandEvent(_ event: RemoteCommandEvent) {
        switch event {
        case .play:
            doris?.play()
            print(">>> Command center play")
        case .pause:
            doris?.pause()
            print(">>> Command center pause")
        case .playPause:
            print(">>> Command center playPause")
        case .stop:
            doris?.stop()
            print(">>> Command center stop")
        case .skipBackward(let double):
            doris?.seek(offset: -double)
            print(">>> Command center skipBackward", double)
        case .skipForward(let double):
            doris?.seek(offset: double)
            print(">>> Command center skipForward", double)
        case .previousTrack:
            print(">>> Command center previousTrack")
        case .nextTrack:
            print(">>> Command center nextTrack")
        case .changePosition(let double):
            doris?.seek(position: double)
            print(">>> Command center changePosition to:", double)
        }
    }

    func onError(_ error: Error) {
        print(error)
    }
}
