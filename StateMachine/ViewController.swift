//
//  ViewController.swift
//  StateMachine
//
//  Created by Curt Clifton on 11/7/15.
//  Copyright © 2015 curtclifton.net. All rights reserved.
//

import UIKit

class ViewController: UIViewController, StenciltownViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    var viewModel: StenciltownViewModel? {
        didSet {
            updateView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
        viewModel?.beginFetch()
    }
    
    func updateView() {
        guard viewIfLoaded != nil else {
            return
        }
        guard let viewModel = self.viewModel else {
            return
        }
        
        if statusLabel.text != viewModel.stateDescription {
            statusLabel.text = viewModel.stateDescription
        }
        downloadButton.isHidden = viewModel.downloadButtonHidden
        downloadButton.isEnabled = viewModel.downloadButtonEnabled
        progressView.isHidden = viewModel.progressBarHidden
        progressView.progress = viewModel.progressBarProgress
    }
    
    @IBAction func download(_ sender: AnyObject) {
        viewModel?.download()
    }
}
