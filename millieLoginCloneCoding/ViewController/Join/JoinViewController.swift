//
//  JoinViewController.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/03.
//

import UIKit

protocol AgencyDelegate{
    func sendValue(selectedAgency: String)
    func dismissedAgency()
}
protocol TermsofUseDelegate{
    func dismissedTermsofUse()
}
protocol SocialJoinDelegate{
    func moveToJoinTermsofUseViewController()
}

class JoinViewController: UIViewController{
    
    private var loginVM: LoginProtocol?
    
    @IBOutlet weak var nameInputView: InputStackView!
    
    @IBOutlet weak var birthStackView: UIStackView!
    @IBOutlet weak var birthTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    
    @IBOutlet weak var agencyStackView: UIStackView!
    @IBOutlet weak var agencyButton: UIButton!
    
    @IBOutlet weak var phoneInputView: InputStackView!
    
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginVM = FirebaseLogin()
        
        setAttribute()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if phoneInputView.isHidden{
            self.phoneInputView.isHidden = false
            self.phoneInputView.textField.becomeFirstResponder()
        }
    }
    
    private func setAttribute(){
        nameInputView.delegate = self
        
        birthStackView.layer.cornerRadius = 5
        birthStackView.layer.borderWidth = 1
        birthStackView.layer.borderColor = UIColor.lightGray.cgColor
        
        birthTextField.delegate = self
        genderTextField.delegate = self
        
        agencyStackView.layer.cornerRadius = 5
        agencyStackView.layer.borderWidth = 1
        agencyStackView.layer.borderColor = UIColor.lightGray.cgColor
        
        phoneInputView.delegate = self
    }
    
    @IBAction private func agencyButtonTap(_ sender: UIButton) {
        self.view.endEditing(true)
        agencyStackView.layer.borderColor = UIColor.black.cgColor
        
        showSheetAgencySelectViewController()
    }
    
    @IBAction private func socialJoinButtonTap(_ sender: UIButton) {
        showSocialJoinViewController()
        
        UIView.animate(withDuration: 0.3, animations:{
            self.view.alpha = 0.5
        })
    }
    
    @IBAction private func nextButtonTap(_ sender: UIButton) {
        self.view.endEditing(true)

        if isInputValidation() == false{
            return
        }
        
        checkJoin()
    }
}

//MARK: extension private Logic

extension JoinViewController{
    private func isInputValidation() -> Bool{
        //입력값 검증
        if phoneInputView.textField.text?.ranges(of: Util.phoneRegex).isEmpty == true &&
            phoneInputView.textField.text?.ranges(of: Util.phone10Regex).isEmpty == true{
            phoneInputView.setInvalidData("휴대폰 번호가 올바르지 않습니다.")
            return false
        }
        if birthStackView.isHidden == true{
//            phoneInputView.setInvalidData(text: "휴대폰 번호가 올바르지 않습니다.")
            return false
        }
        
        return true
    }
    
    @MainActor
    private func checkJoin(){
        Task{
            do{
                try await loginVM?.checkExistingUserPhoneNumber(phone: phoneInputView.textField.text!)
                
                view.endEditing(true)
                agencyStackView.layer.borderColor = UIColor.black.cgColor
                
                showTermsofUseViewController()
            }
            catch{
                presentAlertMessage(message: error.localizedDescription)
            }
        }
    }
    
    private func showSheetAgencySelectViewController(){
        let agencyViewController = AgencySelectViewController(delegate: self)
        agencyViewController.sheetPresentationController?.setCustomFixed()
        
        present(agencyViewController, animated: true)
    }

    private func showSocialJoinViewController(){
        let socialJoinViewController = UIStoryboard(name: "Join", bundle: nil)
            .instantiateViewController(identifier: "SocialJoinViewController"){ (coder) -> SocialJoinViewController? in
                return .init(coder: coder, viewController: self, viewDelegate: self)
            }
        socialJoinViewController.modalPresentationStyle = .overFullScreen

        present(socialJoinViewController, animated: false)
    }

    private func showTermsofUseViewController(){
        let termsofUseViewController = UIStoryboard(name: "Join", bundle: nil)
            .instantiateViewController(identifier: "TermsofUseViewController"){ (coder) -> TermsofUseViewController? in
                return .init(coder: coder, delegate: self)
            }
        termsofUseViewController.sheetPresentationController?.setCustomFixed()
        
        present(termsofUseViewController, animated: true)
    }
    
    private func showNavigationJoinVerificationCodeViewController(){
        let joinVerificationCodeViewController = UIStoryboard(name: "Join", bundle: nil)
            .instantiateViewController(identifier: "JoinVerificationCodeViewController"){ (coder) -> JoinVerificationCodeViewController? in
                return .init(coder: coder, loginVM: self.loginVM)
            }
        
        navigationController?.pushViewController(joinVerificationCodeViewController, animated: true)
    }
    private func showNavigationJoinTermsofUseViewController(){
        let joinTermsofUseViewController = UIStoryboard(name: "Join", bundle: nil)
            .instantiateViewController(identifier: "JoinTermsofUseViewController"){ (coder) -> JoinTermsofUseViewController? in
                return .init(coder: coder, loginVM: self.loginVM)
            }
        
        navigationController?.pushViewController(joinTermsofUseViewController, animated: true)
    }
}


//MARK: extension UITextFieldDelegate

extension JoinViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //시작
        if textField == birthTextField || textField == genderTextField {
            birthStackView.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //끝
        if textField == birthTextField || textField == genderTextField {
            birthStackView.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    //지정된 텍스트 필드에서 텍스트 선택이 변경되면 대리자에게 알립니다.
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == birthTextField{
            if birthTextField.text?.count == 6{
                genderTextField.becomeFirstResponder()
            }
        }
        if textField == genderTextField{
            if genderTextField.text?.count == 1 && birthTextField.text?.count == 6 {
                nameInputView.isHidden = false
                nameInputView.textField.becomeFirstResponder()
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == birthTextField{
            if textField.text?.count == 6  && string != ""{
                return false
            }
        }
        if textField == genderTextField{
            if textField.text?.count == 1  && string != ""{
                return false
            }
        }
        return true
    }
}

//MARK: extension InputStackViewDelegate

extension JoinViewController: InputStackViewDelegate{
    func inputTextFieldDidChangeSelection(_ textField: UITextField) {
        if textField == phoneInputView.textField{
            if textField.text?.ranges(of: Util.phoneRegex).isEmpty == false ||
               textField.text?.ranges(of: Util.phone10Regex).isEmpty == false{
                if agencyStackView.isHidden{
                    agencyStackView.isHidden = false
                    agencyButtonTap(agencyButton)
                }
            }
        }
        if textField == nameInputView.textField{
            nextButton.isEnabled = textField.text!.count > 1
        }
    }
    
    func inputTextField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneInputView.textField{
            if textField.text?.count == 11 && string != ""
            {
                return false
            }
        }
        return true
    }
}


//MARK: extension protocolDelegate

extension JoinViewController: AgencyDelegate{
    func dismissedAgency() {
        agencyStackView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func sendValue(selectedAgency: String){
        agencyButton.setTitle(selectedAgency, for: .normal)
        agencyButton.setTitleColor(.label, for: .normal)
        
        birthStackView.isHidden = false
        birthTextField.becomeFirstResponder()
    }
}

extension JoinViewController: TermsofUseDelegate{
    @MainActor
    func dismissedTermsofUse() {
        guard let phoneNumber = phoneInputView.textField.text else {return}
        Task{
            do{
                try await loginVM?.requestVerificationCode(phoneNumber: phoneNumber)
                showNavigationJoinVerificationCodeViewController()
            }
            catch{
                //알랏
            }
        }
    }
}

extension JoinViewController: SocialJoinDelegate {
    func moveToJoinTermsofUseViewController(){
        self.showNavigationJoinTermsofUseViewController()
    }
}
