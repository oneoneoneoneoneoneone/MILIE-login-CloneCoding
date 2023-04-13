//
//  JoinTermsofUseViewController.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/03.
//

import UIKit

protocol TermsofUseTableViewDelegate{
    func enabledNextButton(isEnabled: Bool)
}

///소셜로그인
class JoinTermsofUseViewController: UIViewController {
    @IBOutlet weak var tableView: TermsofUseTableView!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setData()
    }
    
    private func setData(){
        var terms = Bundle().getplistValue(path: "TermsofUse", key: "terms") as [[String: Any]]
        terms.remove(at: 3)
        
        tableView.setData(data: terms)
        tableView.agreeDelegate = self
    }
    
    @IBAction func nextButtonTap(_ sender: UIButton) {
    }
}

extension JoinTermsofUseViewController: TermsofUseTableViewDelegate{
    func enabledNextButton(isEnabled: Bool) {
        nextButton.isEnabled = isEnabled
    }
}
