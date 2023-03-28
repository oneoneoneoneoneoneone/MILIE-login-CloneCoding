//
//  MainViewController.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/03/29.
//

import UIKit

class MainViewController: UIViewController {
    private var loginVM: LoginViewModel!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginVM = LoginViewModel()
        
        setAttribute()
    }
    
    private func setAttribute(){
        logoutButton.layer.cornerRadius = 5
    }
    
    @IBAction func logoutButtonTap(_ sender: UIButton) {
        self.loginVM.logout()
    }
}

