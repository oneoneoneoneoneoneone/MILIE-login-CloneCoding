//
//  LoginViewController.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/03/28.
//

import UIKit

class LoginViewController: UIViewController {
    private var loginVM: LoginViewModel!
    
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
    
    @IBOutlet weak var phoneNumberLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginVM = LoginViewModel()
        
        setAttribute()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        if loginVM.checkLogin(){
//            guard let mainVC =  UIStoryboard(name: "Main", bundle: nil)
//                .instantiateViewController(withIdentifier: "MainViewController") as? MainViewController else {return}
//            mainVC.modalPresentationStyle = .fullScreen
//
//            self.present(mainVC, animated: true)
//        }
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
        
        loginButton.layer.cornerRadius = 5
        
        kakaoLoginButton.layer.cornerRadius = 25
        naverLoginButton.layer.cornerRadius = 25
        facebookLoginButton.layer.cornerRadius = 25
        appleLoginButton.layer.cornerRadius = 25
        googleLoginButton.layer.cornerRadius = 25
        googleLoginButton.layer.borderWidth = 0.5
        googleLoginButton.layer.borderColor = UIColor.lightGray.cgColor
        
        phoneNumberLoginButton.layer.cornerRadius = 5

   
    }
    @IBAction func loginButtonTap(_ sender: UIButton) {
        guard let phoneNumber = phoneTextField.text,
              let password = passwordTextField.text else {return}
    }
    
    @IBAction func kakaoLoginButtonTap(_ sender: UIButton) {
        
    }
    
    @IBAction func naverLoginButtonTap(_ sender: UIButton) {
        
    }
    
    @IBAction func facebookLoginButtonTap(_ sender: UIButton) {
        
    }
    
    @IBAction func appleLoginButtonTap(_ sender: UIButton) {
        
    }
    
    @IBAction func googleLoginButtonTap(_ sender: UIButton) {
        
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
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        //text 변경
        if phoneTextField.text == "" || passwordTextField.text == "" {
            loginButton.isEnabled = false
        }
        else{
            loginButton.isEnabled = true
        }
    }
}
