//
//  JoinViewController.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/03.
//

import UIKit
import AuthenticationServices

protocol AgencyDelegate{
    func sendValue(selectedAgency: String)
    func dismissed()
}
protocol SocialJoinDelegate{
    func kakaoJoin()
    func naverJoin()
    func facebookJoin()
    func appleJoin()
    func googleJoin()
    
    func socialJoinDismissed()
}

class JoinViewController: UIViewController {
    private var loginVM: FirebaseLogin!
    private var socialLoginVM: SocialLogin!
    
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
        
        //test
        nextButton.isEnabled = true
        
        setAttribute()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loginVM = FirebaseLogin()
        self.socialLoginVM = SocialLogin()
        
        phoneInputView.textField.becomeFirstResponder()
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
        guard let socialJoinViewController =  UIStoryboard(name: "Join", bundle: nil)
            .instantiateViewController(withIdentifier: "SocialJoinViewController") as? SocialJoinViewController else {return}
        socialJoinViewController.delegate = self
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
        loginVM.checkJoin(phone: phoneInputView.textField.text){ [self] result in
            if result{
                //이미 회원임
                return
            }
            
            DispatchQueue.main.async {
                self.view.endEditing(true)
                agencyStackView.layer.borderColor = UIColor.black.cgColor
                
                let termsofUseViewController = TermsofUseViewController()//(delegate: self)
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
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if birthTextField.text?.count == 6 && genderTextField.text?.count == 1{
            nameInputView.isHidden = false
            //@@@@@@@@@@@@@@@@@@@@@@@@@
            //nameInputView 에 포커스 가야해
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == birthTextField{
            if textField.text?.count == 6  && string != ""{
                return false
                //@@@@@@@@@@@@@@@@@@@@@@@@@
                //genderTextField 에 포커스 가야해
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

extension JoinViewController: InputStackViewDelegate{
    func inputTextFieldDidChangeSelection(_ textField: UITextField) {
        if textField == phoneInputView.textField{
            if textField.text?.count == 11{
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

extension JoinViewController: AgencyDelegate{
    func sendValue(selectedAgency: String){
        
        agencyButton.setTitle(selectedAgency, for: .normal)
        agencyButton.setTitleColor(.label, for: .normal)
        
        birthStackView.isHidden = false
    }
    
    func dismissed(){
        agencyStackView.layer.borderColor = UIColor.lightGray.cgColor
        //@@@@@@@@@@@@@@@@@
        //birthStackView 에 포커스 가야해
    }
}

extension JoinViewController: SocialJoinDelegate{
    func kakaoJoin() {
        socialLoginVM.kakaoLogin{result in
            if result{
                //login 성공
                self.dismiss(animated: false)
                self.navigationController?.popToRootViewController(animated: true)
            }
            else{
            }
        }
    }
    
    func naverJoin() {
        
    }
    
    func facebookJoin() {
        
    }
    
    func appleJoin() {
        //firebase 자격증명에 사용할..
        let cryptography = Cryptography()
        let nonce = cryptography.randomNonceString()
        socialLoginVM.currentNonce = nonce
        
        //사용자의 전체 이름과 이메일 주소에 대한 인증 요청을 수행하여 인증 흐름을 시작
        //시스템은 사용자가 기기에서 Apple ID로 로그인했는지 확인
        //설정에서 Apple ID로 로그인하라는 경고를 표시
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        //firebase에서 사용할..
        request.nonce = cryptography.sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func googleJoin() {
        self.socialLoginVM.googleLogin(viewController: self){result in
            if result{
                //login 성공
                self.dismiss(animated: false)
                self.navigationController?.popToRootViewController(animated: true)
            }
            else{
            }
        }
    }
    
    func socialJoinDismissed(){
        view.alpha = 1
    }
}

extension JoinViewController: ASAuthorizationControllerDelegate {
    ///인증에 성공하면 인증 컨트롤러는 앱이 사용자 데이터를 키체인에 저장하는 데 사용하는 위임 기능을 호출
    ///
    ///사용자가 처음 로그인할 때만 표시 이름 등의 사용자 정보를 앱에 공유
    ///이전에 Firebase를 사용하지 않고 Apple을 사용하여 사용자를 앱에 로그인하도록 했으면 Apple은 Firebase에 사용자의 표시 이름을 제공하지 않습니다.
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            //firebase 자격증명 사용
            socialLoginVM.appleLogin(IDToken: idTokenString){result in
                if result{
                    //login 성공
                    DispatchQueue.main.async{
                        self.dismiss(animated: true)
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
                else{
                }
            }
            //appleIDCredential.identityToken - 바뀜
            //appleIDCredential.user - 일정
            //fullName, email - 2번째 로그인부터 안들어옴
        default:
            break
        }
    }
}

///모달 시트에서 사용자에게 Apple로 로그인 콘텐츠를 제공하는 앱에서 창을 가져오는 함수
extension JoinViewController: ASAuthorizationControllerPresentationContextProviding {
    /// - Tag: provide_presentation_anchor
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
