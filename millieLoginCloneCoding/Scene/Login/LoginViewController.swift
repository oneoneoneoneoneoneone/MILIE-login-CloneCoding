//
//  LoginViewController.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/03/28.
//

import UIKit

class LoginViewController: UIViewController {
    private var loginVM: LoginProtocol?
    
    @IBOutlet weak var phoneInputView: InputStackView!
    @IBOutlet weak var passwordInputView: InputStackView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var socialView: SocialView!
        
//    init?(coder: NSCoder, loginVM: FirebaseLoginProtocol? = FirebaseLogin()) {
//        self.loginVM = loginVM
//        super.init(coder: coder)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loginVM = FirebaseLogin()
        
        setAttribute()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setAttribute(){
        socialView.initSocialView(viewController: self)
        
        phoneInputView.delegate = self
        passwordInputView.delegate = self

        loginButton.layer.cornerRadius = 5
    }
    
    @IBAction func loginButtonTap(_ sender: UIButton) {
        guard let phoneNumber = phoneInputView.textField.text,
              let password = passwordInputView.textField.text else {return}
        
        loginVM?.login(phone: phoneNumber, password: password){result in
            if result {
                self.dismiss(animated: true)
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
}

//MARK: extension

extension LoginViewController: InputStackViewDelegate{
    func inputTextFieldDidChangeSelection(_ textField: UITextField) {
        //text 변경
        if phoneInputView.textField.text == "" || passwordInputView.textField.text == "" {
            loginButton.isEnabled = false
        }
        else{
            loginButton.isEnabled = true
        }
    }
}
