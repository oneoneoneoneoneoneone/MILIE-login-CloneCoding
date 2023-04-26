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
    private var socialLoginVM: SocialLoginProtocol?
    private var appleLoginManager: AppleLoginManager?
    
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
        self.socialLoginVM = SocialLogin()
        
        setAttribute()
        
        //test
//        nextButton.isEnabled = true
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
    
    @IBAction func agencyButtonTap(_ sender: UIButton) {
        self.view.endEditing(true)
        agencyStackView.layer.borderColor = UIColor.black.cgColor
        
        let agencyViewController = AgencySelectViewController(delegate: self)
        if let sheet = agencyViewController.sheetPresentationController {
            //크기
            sheet.detents = [.medium(), .large()]
            //무조건 싯트 아래 어둡게
            sheet.largestUndimmedDetentIdentifier = .none
            //크기확장X
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            //아래 고정
            sheet.prefersEdgeAttachedInCompactHeight = true
            //너비 맞춤
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.preferredCornerRadius = 30
        }
        self.present(agencyViewController, animated: true)
    }
    
    @IBAction func socialJoinButtonTap(_ sender: UIButton) {
        let socialJoinViewController = UIStoryboard(name: "Join", bundle: nil)
            .instantiateViewController(identifier: "SocialJoinViewController"){ (coder) -> SocialJoinViewController? in
                return .init(coder: coder, viewController: self, viewDelegate: self)
            }
        socialJoinViewController.modalPresentationStyle = .overFullScreen

        self.present(socialJoinViewController, animated: false)
        
        UIView.animate(withDuration: 0.3, animations:{
            self.view.alpha = 0.5
        })
    }
    
    
    @IBAction func nextButtonTap(_ sender: UIButton) {
        //입력값 검증
        if false{
            return
        }
        //회원 여부 확인
        loginVM?.checkJoin(phone: phoneInputView.textField.text!){ [self] result in
            if result{
                //이미 회원임
                return
            }
            
            //서비스 약관동의 모달
            DispatchQueue.main.async {
                self.view.endEditing(true)
                self.agencyStackView.layer.borderColor = UIColor.black.cgColor
                
                let termsofUseViewController = UIStoryboard(name: "Join", bundle: nil)
                    .instantiateViewController(identifier: "TermsofUseViewController"){ (coder) -> TermsofUseViewController? in
                        return .init(coder: coder, delegate: self)
                    }
                
                if let sheet = termsofUseViewController.sheetPresentationController {
                    //크기
                    sheet.detents = [.medium(), .large()]
                    //무조건 싯트 아래 어둡게
                    sheet.largestUndimmedDetentIdentifier = .none
                    //크기확장X
                    sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                    //아래 고정
                    sheet.prefersEdgeAttachedInCompactHeight = true
                    //너비 맞춤
                    sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
                    sheet.preferredCornerRadius = 30
                }
                self.present(termsofUseViewController, animated: true)
            }
        }
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
            if textField.text!.count > 1{
                nextButton.isEnabled = true
            }
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
    func dismissedTermsofUse() {
        guard let phoneNumber = phoneInputView.textField.text else {return}
        loginVM?.requestVerificationCode(phoneNumber: phoneNumber){result in
            if result{
                let joinVerificationCodeViewController = UIStoryboard(name: "Join", bundle: nil)
                    .instantiateViewController(identifier: "JoinVerificationCodeViewController"){ (coder) -> JoinVerificationCodeViewController? in
                        return .init(coder: coder, loginVM: self.loginVM)
                    }
                
                self.navigationController?.pushViewController(joinVerificationCodeViewController, animated: true)
            }else{
                //알랏
            }
        }
        
    }
}
extension JoinViewController: SocialJoinDelegate {
    func moveToJoinTermsofUseViewController(){
        let joinTermsofUseViewController = UIStoryboard(name: "Join", bundle: nil)
            .instantiateViewController(identifier: "JoinTermsofUseViewController"){ (coder) -> JoinTermsofUseViewController? in
                return .init(coder: coder, loginVM: self.loginVM)
            }
        
        self.navigationController?.pushViewController(joinTermsofUseViewController, animated: true)
    }
}
