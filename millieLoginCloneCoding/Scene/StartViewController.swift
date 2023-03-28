//
//  StartViewController.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/03/28.
//

import UIKit

class StartViewController: UIViewController {
    private var loginVM: LoginViewModel!

    @IBOutlet weak var freeStartButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginVM = LoginViewModel()
        
        setAttribute()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if loginVM.checkLogin(){
            guard let mainVC =  UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "MainViewController") as? MainViewController else {return}
            mainVC.modalPresentationStyle = .fullScreen
            
            self.present(mainVC, animated: true)
        }
    }
    
    private func setAttribute(){
        freeStartButton.layer.cornerRadius = 25
    }
    
}

