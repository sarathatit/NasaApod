//
//  ViewController.swift
//  NASAApod
//
//  Created by Sarath kumar on 09/08/24.
//

import UIKit
import Combine
import Kingfisher

class ApodScreenViewController: UIViewController {

    // MARK: - Outlets Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var fullImageView: UIImageView!
    
    var viewModel: ApodScreenViewModel!
    
    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ApodScreenViewModel(service: WebService())
        observeViewModel()
        setupAlertHandling()
    }
    
    // MARK: - Observer
    func observeViewModel() {
        viewModel.$apodModel
            .sink { [weak self] model in
                self?.updateUI(with: model, isRevisitingToday: self?.viewModel.isRevisitingToday ?? false)
            }
            .store(in: &viewModel.cancellable)
    }
    
    // MARK: - UI Update
    func updateUI(with model: ApodModel?, isRevisitingToday: Bool) {
        if let model = model {
            if isRevisitingToday {
                fullImageView.isHidden = false
                if let urlString = model.url, let url = URL(string: urlString) {
                    fullImageView.kf.setImage(with: url, placeholder: nil, options: [])
                }
            } else {
                fullImageView.isHidden = true
                titleLabel.text = model.title ?? ""
                descriptionLabel.text = model.explanation ?? ""
                dateLabel.text = model.date ?? ""
                if let urlString = model.url, let url = URL(string: urlString) {
                    imageView.kf.setImage(with: url, placeholder: nil, options: [])
                }
            }
        }
    }
    
    // MARK: - Alert
    
    func setupAlertHandling() {
        viewModel.showAlertClosure = { [weak self] in
            self?.showAlert()
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(
            title: "No Internet Connection",
            message: "We are not connected to the internet, showing you the last image we have.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}

