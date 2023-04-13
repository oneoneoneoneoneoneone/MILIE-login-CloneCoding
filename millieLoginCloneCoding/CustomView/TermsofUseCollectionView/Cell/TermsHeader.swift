//
//  TermsHeader.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/12.
//

import UIKit

class TermsHeader: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet weak var allCheckButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
        setAttribute()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func xibSetup() {
        let bundle = Bundle(for: TermsCell.self)
        bundle.loadNibNamed("TermsHeader", owner: self, options: nil)
        
        addSubview(view)
        
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        allCheckButton.configurationUpdateHandler = {[weak self] button in
            switch button.state{
            case .normal:
                button.configuration?.image = .init(systemName: "circle")
            case .selected:
                button.configuration?.image = .init(systemName: "checkmark.circle.fill")
            default: break
            }
        }
    }

    private func setAttribute(){
    }
}
