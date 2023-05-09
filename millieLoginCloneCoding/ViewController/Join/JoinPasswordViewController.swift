//
//  JoinPasswordViewController.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/05/07.
//

import UIKit

class JoinPasswordViewController: UIViewController{
    private var loginVM: LoginProtocol?
    
    @IBOutlet weak var passwordInputView: InputStackView!
    @IBOutlet weak var passwordConfirmInputView: InputStackView!
    @IBOutlet weak var nextButton: UIButton!
    
    required init?(coder: NSCoder, loginVM: LoginProtocol?) {
        self.loginVM = loginVM
        super.init(coder: coder)
    }
    
    @available(*, unavailable, renamed: "init(coder:delegate:)")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setAttribute()
    }
    private func setAttribute(){
        passwordInputView.delegate = self
        passwordConfirmInputView.delegate = self
    }
    
    @IBAction private func nextButtonTap(_ sender: UIButton) {
        requestSavePassword()
        
        showNavigationJoinProfileViewController()
    }
    
    @MainActor
    func requestSavePassword(){
        Task{
            do{
                guard let password = passwordInputView.textField.text else {return}
                try await loginVM?.userInfoUpdate(password: password)
            }catch{
                presentAlertMessage(message: error.localizedDescription)
            }
        }
    }
    
    func showNavigationJoinProfileViewController(){
        let joinProfileViewController =  UIStoryboard(name: "Join", bundle: nil)
            .instantiateViewController(identifier: "JoinProfileViewController"){ (coder) -> JoinProfileViewController? in
            return .init(coder: coder, loginVM: self.loginVM)
        }
        
        self.navigationController?.pushViewController(joinProfileViewController, animated: true)
    }
    
    func validationPasswordConfirmInputData(){
        nextButton.isEnabled = false
        
        if passwordConfirmInputView.textField.text?.isEmpty == false &&
            passwordInputView.textField.isEditing == false &&
            passwordInputView.textField.text?.ranges(of: Util.passwordRegex).isEmpty == false{
            if passwordConfirmInputView.textField.text != passwordInputView.textField.text{
                passwordConfirmInputView.setInvalidData("비밀번호가 일치하지 않습니다")
            }
            if passwordConfirmInputView.textField.text == passwordInputView.textField.text{
                passwordConfirmInputView.setValidData("비밀번호가 일치합니다")
                
                nextButton.isEnabled = true
            }
        }
    }
}

//MARK: extension InputStackViewDelegate

extension JoinPasswordViewController: InputStackViewDelegate{
    func inputTextFieldDidBeginEditing(_ textField: UITextField) {
        if textField == passwordInputView.textField{
            passwordInputView.labelStackView.isHidden = false
            passwordInputView.alertLabel.textColor = .darkGray
            passwordInputView.alertLabel.text = "영어,숫자,특수문자를 조합하여 8~16자로 입력해주세요"
            
            passwordConfirmInputView.textField.delegate?.textFieldDidBeginEditing!(passwordConfirmInputView.textField)
        }
        
        validationPasswordConfirmInputData()
    }
    
    func inputTextFieldDidEndEditing(_ textField: UITextField) {
        if textField == passwordInputView.textField{
            if textField.text?.isEmpty == true{
                passwordInputView.setInvalidData("필수 입력 사항입니다")
                nextButton.isEnabled = false
                return
            }
            if textField.text?.ranges(of: Util.passwordLengthRegex).isEmpty == true{
                passwordInputView.setInvalidData("비밀번호는 8~16자 이내로 입력하세요")
                nextButton.isEnabled = false
                return
            }
            if textField.text?.ranges(of: Util.passwordSpecialCharRegex).isEmpty == false{
                passwordInputView.setInvalidData("특수문자는 !@$^*_-만 입력 가능합니다")
                nextButton.isEnabled = false
                return
            }
            if textField.text?.ranges(of: Util.passwordRegex).isEmpty == true{
                passwordInputView.setInvalidData("특수문자,숫자,영문 조합으로 입력하세요")
                nextButton.isEnabled = false
                return
            }
            if textField.text?.ranges(of: Util.passwordRegex).isEmpty == false{
                passwordInputView.setValidData("사용할 수 있는 비밀번호입니다")
                
                passwordConfirmInputView.textField.delegate?.textFieldDidEndEditing!(passwordConfirmInputView.textField)
                return
            }
        }
        
        validationPasswordConfirmInputData()
    }
    
    func inputTextFieldDidChangeSelection(_ textField: UITextField) {
        validationPasswordConfirmInputData()
    }
    
    func inputTextField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text?.count == 16  && string != ""{
            return false
        }
        return true
    }
}
