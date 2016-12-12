//
//  WhateverViewController.swift
//  RouterExample
//
//  Created by Brandon Sneed on 10/19/15.
//  Copyright © 2015 theholygrail.io. All rights reserved.
//

import UIKit

public class WhateverViewController: UIViewController {
    
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var shownByLabel: UILabel!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func pushedBy(type: String, desc: String) {
        shownByLabel.text = type
        descLabel.text = desc
    }

}