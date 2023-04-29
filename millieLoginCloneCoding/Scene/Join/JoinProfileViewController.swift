//
//  JoinProfileViewController.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/03.
//

import UIKit

class JoinProfileViewController: UIViewController {
    private var loginVM: LoginProtocol?
    
    @IBOutlet weak var profilePhotoButton: UIButton!
    @IBOutlet weak var displayNameInputView: InputStackView!
    @IBOutlet weak var completionButton: UIButton!
    
    init?(coder: NSCoder, loginVM: LoginProtocol?){
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
        displayNameInputView.delegate = self
        
        completionButton.layer.cornerRadius = 5
    }
    
    //프로필 정보 업데이트
    //이미지, 닉네임
    @IBAction func profilePhotoButtonTap(_ sender: UIButton) {
    }
    
    @MainActor
    @IBAction func CompletionButtonTap(_ sender: UIButton) {
        loginVM?.userInfoUpdate(displayName: displayNameInputView.textField.text ?? "", photoURL: "")
        
        Task{
            do{
                try await loginVM?.Join(password: "")
                self.dismiss(animated: true)
                self.navigationController?.popToRootViewController(animated: true)
            }
            catch{
                presentAlertMessage(message: error.localizedDescription)
            }
        }
    }
}

extension JoinProfileViewController: InputStackViewDelegate{
    func inputTextFieldDidChangeSelection(_ textField: UITextField) {
        if textField.text!.count < 1{
            completionButton.isEnabled = false
        }else{
            completionButton.isEnabled = true
        }
        
    }
}
