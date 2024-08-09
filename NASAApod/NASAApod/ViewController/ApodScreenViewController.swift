//
//  ViewController.swift
//  NASAApod
//
//  Created by Sarath kumar on 09/08/24.
//

import UIKit
import Combine

class ApodScreenViewController: UIViewController {

    // MARK: - Outlets Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var viewModel: ApodScreenViewModel!
    
    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ApodScreenViewModel(service: WebService())
        observeViewModel()
    }
    
    // MARK: - Observer
    func observeViewModel() {
        viewModel.$apodModel
            .sink { [weak self] model in
                self?.updateUI(with: model)
            }
            .store(in: &viewModel.cancellable)
    }
    
    // MARK: - UI Update
    func updateUI(with model: ApodModel?) {
        
    }

}

