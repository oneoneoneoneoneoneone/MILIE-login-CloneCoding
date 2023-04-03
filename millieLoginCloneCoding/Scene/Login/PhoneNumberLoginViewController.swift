//
//  PhoneNumberLoginViewController.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/03/28.
//

import UIKit

class PhoneNumberLoginViewController: UIViewController {
    private var loginVM: LoginViewModel!
    
    @IBOutlet weak var phoneInputView: InputStackView!
    @IBOutlet weak var verificationCodeInputView: InputStackView!
    
    @IBOutlet weak var verificationCodeButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loginVM = LoginViewModel()
        
        setAttribute()
    }
    
    private func setAttribute(){
        phoneInputView.delegate = self
        verificationCodeInputView.delegate = self
                
        verificationCodeButton.layer.cornerRadius = 5
        loginButton.layer.cornerRadius = 5
    }
    
    @IBAction func getverificationCodeButtonTap(_ sender: UIButton) {
        guard let phoneNumber = phoneInputView.textField.text else {return}
        
        loginVM.requestVerificationCode(phoneNumber: phoneNumber)
    }
    
    @IBAction func loginButtonTap(_ sender: UIButton) {
        guard let phoneNumber = phoneInputView.textField.text,
              let verificationCode = verificationCodeInputView.textField.text else {return}
        
        loginVM.phoneNumberLogin(phoneNumber: phoneNumber, verificationCode: verificationCode){result in
            if result{
                //login 성공
                self.dismiss(animated: true)
                self.navigationController?.popToRootViewController(animated: true)                
            }
            else{
                print("로그인 실패")
            }
        }
    }
    
}

extension PhoneNumberLoginViewController: InputStackViewDelegate{
    func textFieldDidChangeSelection(_ textField: UITextField) {
        //text 변경
        if phoneInputView.textField.text == "" {
            verificationCodeButton.isEnabled = false
            loginButton.isEnabled = false
        }
        else{
            verificationCodeButton.isEnabled = true
            
            if verificationCodeInputView.textField.text == ""{
                loginButton.isEnabled = false
            }
            else{
                loginButton.isEnabled = true
            }
        }
    }
}
