//
//  TermsofUseViewController.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/07.
//

import UIKit

class TermsofUseViewController: UIViewController{
    var delegate: TermsofUseDelegate!
    
    @IBOutlet weak var tableView: TermsofUseTableView!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setData()
    }
    
    private func setData(){
        var terms = Bundle().getplistValue(path: "TermsofUse", key: "terms") as [[String: Any]]
        terms.remove(at: 0)

        tableView.setData(data: terms)
        tableView.agreeDelegate = self
    }
    
    @IBAction func nextButtonTap(_ sender: UIButton) {
        dismiss(animated: true){
            self.delegate?.dismissedTermsofUse()
        }
    }
}

extension TermsofUseViewController: TermsofUseTableViewDelegate{
    func enabledNextButton(isEnabled: Bool) {
        nextButton.isEnabled = isEnabled
    }
}
