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
        
        addSubview(tableViewCell)
        
        tableViewCell.frame = bounds
        tableViewCell.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        tableViewCell.selectionStyle = .none
        
        checkButton.configurationUpdateHandler = {[weak self] button in
            switch button.state{
            case .normal:
                button.configuration?.image = .init(systemName: "square")
            case .selected:
                button.configuration?.image = .init(systemName: "checkmark.square.fill")
            default: break
            }
        }
    }

    private func setAttribute(){
    }
}
