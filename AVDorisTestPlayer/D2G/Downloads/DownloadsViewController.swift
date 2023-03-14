//
//  DownloadsViewController.swift
//  DLM-poc
//
//  Created by Lukasz on 02/07/2018.
//  Copyright © 2020 Endeavor Streaming. All rights reserved.
//

import UIKit
import AVKit

// MARK: Implementation
class DownloadsViewController: UITableViewController {
    private let presenter = DownloadsPresenterImpl()
    fileprivate var playerViewController: AVPlayerViewController?
            
    private var tableItems: [CellViewModel] = []
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none

        tableView.registerClass(DownloadTableViewCell.self)
        presenter.onViewDidLoad(self)
    }
    
    // MARK: DownloadView
    func setData(data: [CellViewModel]) {
        tableItems = data
        tableView.reloadData()
    }
    
    // MARK: BaseView
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error",
                                      message: message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "OK",
                                   style: UIAlertAction.Style.default,
                                   handler: nil)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func showLoading() {
        LoadingOverlay.shared.showOverlay(view.superview ?? view)
    }
    
    func hideLoading() {
        LoadingOverlay.shared.hideOverlayView()
    }    
}

extension DownloadsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableItems.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DownloadTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        let viewModel = tableItems[indexPath.row]
        cell.delegate = self
        cell.viewModel = viewModel
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white
        
        let pauseAllButton = UIButton(type: .system)
        pauseAllButton.setTitle("Pause All", for: .normal)
        pauseAllButton.addAction(for: .touchUpInside) { [unowned self] in
            self.presenter.pauseAll()
        }
        let resumeAllButton = UIButton(type: .system)
        resumeAllButton.setTitle("Resume All", for: .normal)
        resumeAllButton.addAction(for: .touchUpInside) { [unowned self] in
            self.presenter.resumeAll()
        }
        let cancelAllButton = UIButton(type: .system)
        cancelAllButton.setTitle("Cancel All", for: .normal)
        cancelAllButton.addAction(for: .touchUpInside) { [unowned self] in
            self.presenter.cancelAll()
        }
        let addDownloadButton = UIButton(type: .system)
        addDownloadButton.setTitle("Add download", for: .normal)
        addDownloadButton.addAction(for: .touchUpInside) { [unowned self] in
            //1. Create the alert controller.
            let alert = UIAlertController(title: "Add download", message: "Enter VOD id", preferredStyle: .alert)

            //2. Add the text field. You can configure it however you need.
            alert.addTextField { (textField) in
                textField.placeholder = "VOD id"
                textField.keyboardType = .numberPad
            }

            // 3. Grab the value from the text field, and print it when the user clicks OK.
            alert.addAction(UIAlertAction(title: "Download", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields?[0] // Force unwrapping because we know it exists.
                self.presenter.addDownload(id: textField?.text)
            }))

            // 4. Present the alert.
            self.present(alert, animated: true, completion: nil)
            
        }
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 5
        stackView.addArrangedSubviews([addDownloadButton, pauseAllButton, resumeAllButton, cancelAllButton])
        
        view.addSubview(stackView)
        stackView.fillSuperview()
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 350
    }
}

extension DownloadsViewController: DownloadTableViewCellDelegate {
    func onPlayButtonTapped(viewModel: CellViewModel?) {
        guard let viewModel = viewModel else { return }
        self.presenter.playDownload(viewModel: viewModel)
    }
    
    func onRenewButtonTapped(viewModel: CellViewModel?) {
        guard let viewModel = viewModel else { return }
        presenter.renewLicense(viewModel: viewModel)
    }
    
    func onDeleteButtonTapped(viewModel: CellViewModel?) {
        guard let viewModel = viewModel else { return }
        presenter.removeDownload(viewModel: viewModel)
    }
    
    func onPauseButtonTapped(viewModel: CellViewModel?) {
        guard let viewModel = viewModel else { return }
        presenter.pauseDownload(viewModel: viewModel)
    }
    
    func onResumeButtonTapped(viewModel: CellViewModel?) {
        guard let viewModel = viewModel else { return }
        presenter.resumeDownload(viewModel: viewModel)
    }
}
