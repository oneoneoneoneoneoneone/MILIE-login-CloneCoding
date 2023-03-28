//
//  LoginViewController.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/03/28.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var phoneStackView: UIStackView!
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var passwordStackView: UIStackView!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var kakaoLoginButton: UIButton!
    @IBOutlet weak var naverLoginButton: UIButton!
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var appleLoginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAttribute()
    }
    
    private func setAttribute(){
        phoneTextField.delegate = self
        passwordTextField.delegate = self
        
        phoneStackView.layer.cornerRadius = 5
        phoneStackView.layer.borderWidth = 1
        phoneStackView.layer.borderColor = UIColor.lightGray.cgColor
        
        passwordStackView.layer.cornerRadius = 5
        passwordStackView.layer.borderWidth = 1
        passwordStackView.layer.borderColor = UIColor.lightGray.cgColor
        
        kakaoLoginButton.layer.cornerRadius = 25
        naverLoginButton.layer.cornerRadius = 25
        facebookLoginButton.layer.cornerRadius = 25
        appleLoginButton.layer.cornerRadius = 25
        googleLoginButton.layer.cornerRadius = 25
        googleLoginButton.layer.borderWidth = 0.5
        googleLoginButton.layer.borderColor = UIColor.lightGray.cgColor

   
    }

    @IBAction func kakaoLoginButton(_ sender: UIButton) {
        
    }
    
    @IBAction func naverLoginButton(_ sender: UIButton) {
        
    }
    
    @IBAction func facebookLoginButton(_ sender: UIButton) {
        
    }
    
    @IBAction func appleLoginButton(_ sender: UIButton) {
        
    }
    
    @IBAction func googleLoginButton(_ sender: UIButton) {
        
    }
}

extension LoginViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //시작
        if textField == phoneTextField {
            phoneStackView.layer.borderColor = UIColor.black.cgColor
        }
        if textField == passwordTextField{
            passwordStackView.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //끝
        if textField == phoneTextField {
            phoneStackView.layer.borderColor = UIColor.lightGray.cgColor
        }
        if textField == passwordTextField{
            passwordStackView.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
}
