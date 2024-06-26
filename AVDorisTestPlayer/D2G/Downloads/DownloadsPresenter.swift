//
//  DownloadsPresenter.swift
//  DLM-poc
//
//  Created by Lukasz on 02/07/2018.
//  Copyright © 2020 Endeavor Streaming. All rights reserved.
//

import Foundation
import AVKit
import dice_shield_ios

// MARK: Implementation
class DownloadsPresenterImpl: DownloadProviderDelegate {
    private var downloadProvider: DownloadProviderOnCallbacks = DiceShield.sharedProvider
    private let networkManager = NetworkingManager()
    
    private weak var view: DownloadsViewController?
    
    var viewModels: [CellViewModel] = []
    
    func onViewDidLoad(_ view: DownloadsViewController) {
        self.view = view
        
        let config = APIConfig(baseURL: Constants.baseURL,
                               apiKey: Constants.apiKey,
                               realm: Constants.realm,
                               deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "",
                               headers: [:])
        downloadProvider.setup(config: config)
        downloadProvider.restoreSuspendedDownloads()
        
        getCachedData()
        setupDownloadsObserver()
    }
    
    func getCachedData() {
        view?.showLoading()
        downloadProvider.getAllDownloads() { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.view?.hideLoading()
                switch result {
                case .success(let assets):
                    self.viewModels = assets.map { CellViewModel(id: $0.id, progress: $0.downloadProgress, downloadState: $0.downloadState, expiryDate: $0.expiryDate) }
                    self.view?.setData(data: self.viewModels)
                default:
                    break
                }
            }
        }
    }
    
    func downloadDidUpdate(withData data: DownloadUpdateInfo) {
        DispatchQueue.main.async {
            if !self.viewModels.contains(where: {$0.id == data.assetId}), data.state != .notDownloaded {
                self.viewModels.append(CellViewModel(id: data.assetId,
                                                     progress: data.progress,
                                                     downloadState: data.state,
                                                     expiryDate: data.expiryDate))
            }
            
            for viewModel in self.viewModels {
                if viewModel.id == data.assetId {
                    viewModel.progress = data.progress
                    viewModel.downloadState = data.state
                    viewModel.expiryDate = data.expiryDate
                }
            }
            
            self.view?.setData(data: self.viewModels)
        }
    }
    
    func setupDownloadsObserver() {
        downloadProvider.delegate = self
    }
    
    func addDownload(id: String?) {
        guard let id = id else { return }
        view?.showLoading()
        
        let asset = DownloadableAsset(itemId: id,
                                      title: "test",
                                      extraData: nil,
                                      images: nil,
                                      quality: .HIGH,
                                      language: "eng")
        
        //you do not need to do this if you already have auth tokens
        networkManager.authorize(
            headers: DiceHeaders(realm: Constants.realm, apiKey: Constants.apiKey, baseURL: Constants.baseURL),
            username: Constants.userName,
            password: Constants.password,
            success: { [weak self] (tokens) in
                self?.downloadProvider.setToken(newToken: tokens.authorisationToken)
                
                self?.downloadProvider.addDownload(asset: asset) { [weak self] result in
                    DispatchQueue.main.async {
                        self?.view?.hideLoading()
                        switch result {
                        case .success:
                            return
                        case .failure(let error):
                            if let error = error as? DiceShieldError, error.kind == .unauthorized {
                                self?.refreshToken(tokens: Tokens(token: "", refreshToken: ""))
                            }
                            self?.view?.showError(error.localizedDescription)
                            return
                        }
                    }
                }
            }, failure: { [weak self] error in
                self?.view?.showError(error?.localizedDescription ?? "")
            })
    }
    
    func pauseDownload(viewModel: CellViewModel) {
        self.downloadProvider.pauseDownload(itemID: viewModel.id) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    break
                case .failure(let error):
                    self.view?.showError("\(error)")
                }
            }
        }
    }
    
    func resumeDownload(viewModel: CellViewModel) {
        self.downloadProvider.resumeDownload(itemID: viewModel.id) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    break
                case .failure(let error):
                    self.view?.showError("\(error)")
                }
            }
        }
    }
    
    func pauseAll() {
        self.downloadProvider.pauseAllDownloads { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    return
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func resumeAll() {
        self.downloadProvider.resumeAllDownloads { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    return
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func cancelAll() {
        self.downloadProvider.cancelAllDownloads { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.viewModels.removeAll(where: {$0.downloadState == .notDownloaded})
                    self.view?.setData(data: self.viewModels)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func renewLicense(viewModel: CellViewModel) {
        view?.showLoading()
        
        networkManager.authorize(
            headers: DiceHeaders(realm: Constants.realm, apiKey: Constants.apiKey, baseURL: Constants.baseURL),
            username: Constants.userName,
            password: Constants.password,
            success: { [weak self] (tokens) in
                self?.downloadProvider.setToken(newToken: tokens.authorisationToken)
                
                self?.downloadProvider.renewLicense(id: viewModel.id) { [weak self] (result) in
                    DispatchQueue.main.async {
                        self?.view?.hideLoading()
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            if let error = error as? DiceShieldError, error.kind == .unauthorized {
                                self?.refreshToken(tokens: Tokens(token: "", refreshToken: ""))
                            }
                            self?.view?.showError(error.localizedDescription)
                        }
                    }
                }
            }, failure: { _ in
                
            })
    }
    
    func removeDownload(viewModel: CellViewModel) {
        view?.showLoading()
        downloadProvider.removeDownload(itemId: viewModel.id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    self?.view?.hideLoading()
                    self?.view?.showError("\(error)")
                case .success:
                    self?.viewModels.removeAll(where: {$0.id == viewModel.id})
                    self?.view?.setData(data: self?.viewModels ?? [])
                    self?.view?.hideLoading()
                }
            }
        }
    }
    
    func playDownload(viewModel: CellViewModel) {
        downloadProvider.getDownload(forId: viewModel.id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    guard let localUrl = data.localFileUrl else { return }
                    self?.view?.present(CustomAVPlayerViewController(.downloadedSource(filePath: localUrl)), animated: true)
                case .failure(let error):
                    self?.view?.showError(error.localizedDescription)
                }
            }
        }
    }
    
    private func refreshToken(tokens: Tokens) {
        networkManager.refreshToken(headers: DiceHeaders(realm: Constants.realm,
                                                         apiKey: Constants.apiKey,
                                                         baseURL: Constants.baseURL),
                                    tokens: tokens, success: { [weak self] token in
            self?.downloadProvider.setToken(newToken: token)
        }) { error in
            self.view?.showError(error?.localizedDescription ?? "")
        }
    }
}
