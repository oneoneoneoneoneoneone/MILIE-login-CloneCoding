//
//  MainViewController.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/03/29.
//

import UIKit

class MainViewController: UIViewController {
    private var loginVM: LoginProtocol?
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginVM = FirebaseLogin()
        
        setAttribute()
    }
    
    private func setAttribute(){
        logoutButton.layer.cornerRadius = 5
        
        userNameLabel.text = loginVM?.getCurrentUser()?.displayName
    }
    
    @IBAction func logoutButtonTap(_ sender: UIButton) {
        do{
            try loginVM?.logout()
            self.dismiss(animated: true)
        }
        catch{
            presentAlertMessage(message: error.localizedDescription)
        }
    }
}
