//
//  JoinVerificationCodeViewController.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/03/28.
//

import UIKit

class JoinVerificationCodeViewController: UIViewController {
    private var loginVM: FirebaseLoginProtocol!
    
    @IBOutlet weak var verificationCodeInputView: InputStackView!
    
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    init(loginVM: FirebaseLoginProtocol!) {
        self.loginVM = loginVM
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setAttribute()
    }
    
    private func setAttribute(){
        verificationCodeInputView.delegate = self
        
        nextButton.layer.cornerRadius = 5
    }
    
    @IBAction func resendButtonTap(_ sender: UIButton) {
        loginVM.requestVerificationCode(phoneNumber: ""){result in
            if result{
                //재전송
            }else{
                //싫패
            }
        }
    }
    
    @IBAction func nextButtonTap(_ sender: UIButton) {
        guard let verificationCode = verificationCodeInputView.textField.text else {return}
        
        loginVM.phoneNumberLogin(verificationCode: verificationCode){result in
            if result{
                //login 성공
                guard let joinProfileViewController =  UIStoryboard(name: "Join", bundle: nil)
                    .instantiateViewController(withIdentifier: "JoinProfileViewController") as? JoinProfileViewController else {return}
                
                self.navigationController?.pushViewController(joinProfileViewController, animated: true)
            }
            else{
                print("로그인 실패")
            }
        }
    }
    
}

extension JoinVerificationCodeViewController: InputStackViewDelegate{
    func inputTextFieldDidChangeSelection(_ textField: UITextField) {
        if textField.text == "" {
            nextButton.isEnabled = false
        }
        else{
            nextButton.isEnabled = true
        }
    }
    
    func inputTextField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        true
    }
}
