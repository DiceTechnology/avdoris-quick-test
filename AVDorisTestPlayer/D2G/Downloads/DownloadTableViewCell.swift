//
//  DownloadItemView.swift
//  DLM-poc
//
//  Created by Lukasz on 02/07/2018.
//  Copyright © 2020 Endeavor Streaming. All rights reserved.
//

import UIKit
import dice_shield_ios

protocol DownloadTableViewCellDelegate: AnyObject {
    func onPlayButtonTapped(viewModel: CellViewModel?)
    func onRenewButtonTapped(viewModel: CellViewModel?)
    func onDeleteButtonTapped(viewModel: CellViewModel?)
    func onPauseButtonTapped(viewModel: CellViewModel?)
    func onResumeButtonTapped(viewModel: CellViewModel?)
}

class CellViewModel {
    var id: String
    var progress: Double
    var downloadState: AssetDownloadState?
    var expiryDate: Date?
    
    init(id: String, progress: Double, downloadState: AssetDownloadState?, expiryDate: Date?) {
        self.id = id
        self.progress = progress
        self.downloadState = downloadState
        self.expiryDate = expiryDate
    }
}

class DownloadTableViewCellView: BaseView {
    let progressView = UIProgressView()
    let expiryLabel = UILabel()
    let downloadStateLabel = UILabel()
    let titleLabel = UILabel()
    
    let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        return view
    }()
    
    let playButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Play", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()
    
    let pauseButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Pause downloading", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()
    
    let resumeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Resume downloading", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()
    
    let renewButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Renew license", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Delete", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 8
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    @available(*, unavailable) override func addSubviews() {
        stackView.addArrangedSubviews([
            titleLabel,
            expiryLabel,
            downloadStateLabel,
            progressView,
            playButton,
            pauseButton,
            resumeButton,
            renewButton,
            deleteButton,
            separator]
        )
        
        addSubviews([stackView])
    }
    
    @available(*, unavailable) override func anchorSubviews() {
        stackView.fillSuperview()
        separator.anchorHeight(10)
    }
}

class DownloadTableViewCell: BaseTableViewCell<DownloadTableViewCellView> {
    public static let reuseId = "DownloadTableViewCell"
    
    weak var delegate: DownloadTableViewCellDelegate?
    
    var viewModel: CellViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            mainView.titleLabel.text = "VOD(\(viewModel.id))"
            mainView.progressView.progress = Float(viewModel.progress)
            mainView.downloadStateLabel.text = viewModel.downloadState?.rawValue ?? AssetDownloadState.notDownloaded.rawValue
            
            if let date = viewModel.expiryDate {
                if date < Date() {
                    mainView.expiryLabel.text = "license expired"
                } else {
                    mainView.expiryLabel.text = "exp: " + DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)
                }
            } else {
                mainView.expiryLabel.text = nil
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        mainView.playButton.addAction(for: .touchUpInside) { [weak self] in
            self?.delegate?.onPlayButtonTapped(viewModel: self?.viewModel)
        }
        
        mainView.pauseButton.addAction(for: .touchUpInside) { [weak self] in
            self?.delegate?.onPauseButtonTapped(viewModel: self?.viewModel)
        }
        
        mainView.resumeButton.addAction(for: .touchUpInside) { [weak self] in
            self?.delegate?.onResumeButtonTapped(viewModel: self?.viewModel)
        }
        
        mainView.renewButton.addAction(for: .touchUpInside) { [weak self] in
            self?.delegate?.onRenewButtonTapped(viewModel: self?.viewModel)
        }
        
        mainView.deleteButton.addAction(for: .touchUpInside) { [weak self] in
            self?.delegate?.onDeleteButtonTapped(viewModel: self?.viewModel)
        }
    }
    
    override func prepareForReuse() {
        mainView.progressView.progress = 0
        mainView.downloadStateLabel.text = "-"
        mainView.expiryLabel.text = "-- MB/s"
    }
}
