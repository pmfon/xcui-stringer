//
//  ViewController.swift
//  xcuistringer-sample
//
//  Created by Pedro Fonseca on 05/11/16.
//  Copyright © 2016 Pedro Fonseca. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var failImage: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func didTapButton(sender: UIButton) {
    
        self.view.setNeedsLayout()
        
        failImage?.isHidden = false;
        sender.setTitle("Eeeek!", for: UIControlState.normal)
    }

}

