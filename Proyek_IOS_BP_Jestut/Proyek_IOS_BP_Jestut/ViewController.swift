//
//  ViewController.swift
//  Proyek_IOS_BP_Jestut
//
//  Created by IOS on 03/12/20.
//  Copyright © 2020 Petra. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBAction func btnCreateWorkour(_ sender: UIButton) {
        performSegue(withIdentifier: "MainToTitleWorkout", sender: self)
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

