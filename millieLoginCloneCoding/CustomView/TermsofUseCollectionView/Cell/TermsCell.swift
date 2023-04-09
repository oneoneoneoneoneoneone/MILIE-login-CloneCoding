//
//  TermsCell.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/07.
//

import UIKit

class TermsCell: UITableViewCell {
    @IBOutlet var tableViewCell: UITableViewCell!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var detailButton: UIButton!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        xibSetup()
        setAttribute()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func xibSetup() {
        let bundle = Bundle(for: TermsCell.self)
        bundle.loadNibNamed("TermsCell", owner: self, options: nil)
        
        tableViewCell.frame = bounds
        tableViewCell.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(tableViewCell)
        tableViewCell.selectionStyle = .none
    }

    private func setAttribute(){
    }
}

//extension UITableViewCell {
//    func loadViewFromNib(nib: String) -> UIView? {
//        let bundle = Bundle(for: type(of: self))
//        let nib = UINib(nibName: nib, bundle: bundle)
//        return nib.instantiate(withOwner: self, options: nil).first as? UIView
//    }
//}
