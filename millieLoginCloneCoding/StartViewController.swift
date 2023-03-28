//
//  StartViewController.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/03/28.
//

import UIKit

class StartViewController: UIViewController {

    @IBOutlet weak var freeStartButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
    }
    
    private func setAttribute(){
        freeStartButton.layer.cornerRadius = 25
   
    }
    
}

