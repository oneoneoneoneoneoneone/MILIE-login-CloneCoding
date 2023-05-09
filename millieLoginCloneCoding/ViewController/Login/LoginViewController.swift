//
//  LoginViewController.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/03/28.
//

import UIKit
import LocalAuthentication

class LoginViewController: UIViewController {
    private var loginVM: LoginProtocol?
    
    @IBOutlet weak var phoneInputView: InputStackView!
    @IBOutlet weak var passwordInputView: InputStackView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var socialView: SocialView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loginVM = FirebaseLogin()
        
        setAttribute()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loginFaceID()
    }
    
    private func setAttribute(){
        socialView.initSocialView(viewController: self)
        
        phoneInputView.delegate = self
        passwordInputView.delegate = self
        
        loginButton.layer.cornerRadius = 5
    }
    
    @MainActor
    @IBAction func loginButtonTap(_ sender: UIButton) {
        guard let phoneNumber = phoneInputView.textField.text,
              let password = passwordInputView.textField.text else {return}
        
        Task{
            do{
                try await loginVM?.login(phone: phoneNumber, password: password)
                
                if try KeyChainManager.isEmpty(){
                    try KeyChainManager.add(account: phoneNumber, password: password)
                }else{
                    try KeyChainManager.update(account: phoneNumber, password: password)
                }
                
                self.dismiss(animated: true)
                self.navigationController?.popToRootViewController(animated: true)
            }
            catch{
                presentAlertMessage(message: error.localizedDescription)
            }
        }
    }
    
    func loginFaceID(){
        Task{
            do{
                if try KeyChainManager.isEmpty() {
                    return
                }
                
                let context = LAContext()
                context.localizedCancelTitle = "휴대폰번호/비밀번호 로그인하기"
                
                var error: NSError?
                guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
                    throw error ?? LoginError.unknown(key: "Can't evaluate policy")
                }
                
                try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Log in to your account")
                try await KeyChainManager.read()
                
                self.dismiss(animated: true)
                self.navigationController?.popToRootViewController(animated: true)
            }
            catch{
                if error.localizedDescription == "Authentication canceled."{
                    return
                }
                presentAlertMessage(message: error.localizedDescription)
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
