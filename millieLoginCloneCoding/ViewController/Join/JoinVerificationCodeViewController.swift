//
//  JoinVerificationCodeViewController.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/03/28.
//

import UIKit

class JoinVerificationCodeViewController: UIViewController {
    private var loginVM: LoginProtocol?
    
    @IBOutlet weak var verificationCodeInputView: InputStackView!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    private var timer: Timer = Timer()
    private var timeLimit: Int = 180
    
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
        setTimer()
    }
    
    private func setAttribute(){
        verificationCodeInputView.delegate = self
    }
    
    @IBAction private func resendButtonTap(_ sender: UIButton) {
        requestVerificationCode()
    }
    
    @IBAction private func nextButtonTap(_ sender: UIButton) {
        if timer.isValid == false {
            presentAlertMessage(message: "입력 가능 시간이 만료되었습니다")
            verificationCodeInputView.textField.text = ""
        }
        
        guard let verificationCode = verificationCodeInputView.textField.text else {return}
        phoneNumberLogin(verificationCode: verificationCode)
    }
    
    @objc private func timerCallback(){
        if timeLimit < 2{
            timer.invalidate()
        }
        timeLimit -= 1
        setAccessoryLabelText()
    }
    
    private func setTimer(){
        timeLimit = 180
        setAccessoryLabelText()
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
    }
    
    private func setAccessoryLabelText(){
        let time = Date(timeIntervalSince1970: TimeInterval(timeLimit))
        
        verificationCodeInputView.accessoryLabel.text = Util.timeFormatter.string(from: time)
    }
}

//MARK: extension private Logic

extension JoinVerificationCodeViewController{
    @MainActor
    func requestVerificationCode(){
        Task{
            do{
                try await loginVM?.requestVerificationCode()
                setTimer()
            }
            catch{
                presentAlertMessage(message: error.localizedDescription)
            }
        }
    }
    
    @MainActor
    func phoneNumberLogin(verificationCode: String){
        Task{
            do{
                try await loginVM?.phoneNumberLogin(verificationCode: verificationCode)
                showNavigationJoinPasswordViewController()
            }
            catch{
                presentAlertMessage(message: error.localizedDescription)
            }
        }
    }
    
    func showNavigationJoinPasswordViewController(){
        let joinPasswordViewController =  UIStoryboard(name: "Join", bundle: nil)
            .instantiateViewController(identifier: "JoinPasswordViewController"){ (coder) -> JoinPasswordViewController? in
            return .init(coder: coder, loginVM: self.loginVM)
        }
        
        self.navigationController?.pushViewController(joinPasswordViewController, animated: true)
    }
}

//MARK: extension InputStackViewDelegate

extension JoinVerificationCodeViewController: InputStackViewDelegate{
    func inputTextFieldDidChangeSelection(_ textField: UITextField) {
        if textField.text?.count == 6 {
            nextButton.isEnabled = true
            return
        }
        nextButton.isEnabled = false
    }
    
    func inputTextField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text?.count == 6  && string != ""{
            return false
        }
        return true
    }
}
