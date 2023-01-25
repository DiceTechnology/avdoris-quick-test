//
//  DorisCastManager.swift
//  AVDorisTestPlayer
//
//  Created by Yaroslav Lvov on 25.01.2023.
//  Copyright © 2023 Endeavor Streaming. All rights reserved.
//

import Foundation
import GoogleCast

protocol DorisCastManagerDelegate: AnyObject {
    func castStateDidChange(isConnected: Bool)
}

class DorisCastManager: NSObject {
    weak var delegate: DorisCastManagerDelegate?
    
    ///
    ///You might also want to change this value inside Info.plist -> Bonjour services -> Item 1
    ///_<kReceiverAppID>._googlecast._tcp
    static let kReceiverAppID = "770C3773"
    ///authToken
    private let authToken = ""
    ///refreshToken
    private let refreshToken = ""
    ///videoID
    private let videoID = 71674
    ///realm
    private let realm = "dce.sandbox"
        
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(castStateDidChange),
                                               name: .gckCastStateDidChange,
                                               object: nil)
    }
    
    @objc func castStateDidChange() {
        delegate?.castStateDidChange(isConnected: GCKCastContext.sharedInstance().castState == .connected)
    }
    
    func cast() {
        let customData = createCustomData()
        let metadata = GCKMediaMetadata(metadataType: .movie)
        metadata.setString("Doris Test", forKey: kGCKMetadataKeyTitle)

        let builder = GCKMediaInformationBuilder()
        builder.contentID = "\(videoID)"
        builder.streamType = GCKMediaStreamType.buffered
        builder.textTrackStyle = nil
        builder.streamDuration = -1
        builder.customData = customData
        builder.metadata = metadata
        
        let mediaLoadOptions = GCKMediaLoadOptions.init()
        mediaLoadOptions.playPosition = 0
        mediaLoadOptions.autoplay = true
        
        if let remoteMediaClient = GCKCastContext.sharedInstance().sessionManager.currentCastSession?.remoteMediaClient {
            let request = remoteMediaClient.loadMedia(builder.build(), with: mediaLoadOptions)
            request.delegate = self
        }
    }
    
    private func createCustomData() -> [String: AnyHashable]? {
        var resolutionData: [String: AnyHashable] = [:]
        resolutionData["isLive"] = false

        var beaconData: [String: AnyHashable] = [:]
        beaconData["action"] = 2
        beaconData["cid"] = "3eb419eb-5fb2-4cfd-82a8-023317fb1131"
        beaconData["startedAt"] = 0
        beaconData["video"] = videoID
        beaconData["progress"] = 0
        beaconData["endpoint"] = "https://guide.imggaming.com/prod"
        
        var sessionData: [String: AnyHashable] = [:]
        sessionData["baseUrl"] = "https://dce-frontoffice.imggaming.com/api/v2"
        sessionData["beacon"] = beaconData
        sessionData["realm"] = realm
        sessionData["authorisationToken"] = authToken
        sessionData["refreshToken"] = refreshToken
                
        var customData: [String: AnyHashable] = [:]
        customData["sourceType"] = "resolvable"
        customData["resolutionType"] = "dice"
        customData["resolutionCustomData"] = resolutionData
        
        guard let sessionDataJSON = try? JSONSerialization.data(withJSONObject: sessionData) else { return nil }
        guard let sessionDataSerialized = String(data: sessionDataJSON, encoding: .utf8) else { return nil }
        customData["chromecastSessionSerialized"] = sessionDataSerialized
        
        print("Cast custom data:", customData.prettyPrintedJSONString)

        return customData
    }
}

extension DorisCastManager: GCKSessionManagerListener, GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        print("Cast request \(Int(request.requestID)) completed")
    }
    
    func request(_ request: GCKRequest, didAbortWith abortReason: GCKRequestAbortReason) {
        print("Cast request \(Int(request.requestID)) completed \(abortReason)")
    }
    
    func request(_ request: GCKRequest, didFailWithError error: GCKError) {
        print("Cast request \(Int(request.requestID)) failed with error \(error)")
    }
}
