//
//  PhoneNumberLoginViewController.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/03/28.
//

import UIKit

class PhoneNumberLoginViewController: UIViewController {
    private var loginVM: LoginViewModel!
    
    @IBOutlet weak var phoneStackView: UIStackView!
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var verificationCodeButton: UIButton!
    
    @IBOutlet weak var verificationCodeStackView: UIStackView!
    @IBOutlet weak var verificationCodeTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loginVM = LoginViewModel()
        
        setAttribute()
    }
    
    private func setAttribute(){
        phoneTextField.delegate = self
        verificationCodeTextField.delegate = self
        
        phoneStackView.layer.cornerRadius = 5
        phoneStackView.layer.borderWidth = 1
        phoneStackView.layer.borderColor = UIColor.lightGray.cgColor
        
        verificationCodeStackView.layer.cornerRadius = 5
        verificationCodeStackView.layer.borderWidth = 1
        verificationCodeStackView.layer.borderColor = UIColor.lightGray.cgColor
        
        verificationCodeButton.layer.cornerRadius = 5
        loginButton.layer.cornerRadius = 5
        
    }
    
    @IBAction func getverificationCodeButtonTap(_ sender: UIButton) {
        guard let phoneNumber = phoneTextField.text else {return}
        
        loginVM.requestVerificationCode(phoneNumber: phoneNumber)
    }
    
    @IBAction func loginButtonTap(_ sender: UIButton) {
        guard let phoneNumber = phoneTextField.text,
              let verificationCode = verificationCodeTextField.text else {return}
        
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

extension PhoneNumberLoginViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //시작
        if textField == phoneTextField {
            phoneStackView.layer.borderColor = UIColor.black.cgColor
        }
        if textField == verificationCodeTextField{
            verificationCodeTextField.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //끝
        if textField == phoneTextField {
            phoneStackView.layer.borderColor = UIColor.lightGray.cgColor
        }
        if textField == verificationCodeTextField{
            verificationCodeTextField.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        //text 변경
        if phoneTextField.text == "" {
            verificationCodeButton.isEnabled = false
            loginButton.isEnabled = false
        }
        else{
            verificationCodeButton.isEnabled = true
            
            if verificationCodeTextField.text == ""{
                loginButton.isEnabled = false
            }
            else{
                loginButton.isEnabled = true
            }
        }
    }
}
