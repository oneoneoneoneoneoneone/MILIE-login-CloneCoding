//
//  InputStackView.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/03.
//

import UIKit

@objc protocol InputStackViewDelegate{
    @objc optional func inputTextFieldDidBeginEditing(_ textField: UITextField)
    @objc optional func inputTextFieldDidEndEditing(_ textField: UITextField)
    @objc optional func inputTextFieldDidChangeSelection(_ textField: UITextField)
    @objc optional func inputTextField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
}

@IBDesignable
class InputStackView: UIView {
    @IBOutlet var view: UIView!
    
    @IBOutlet weak var hStackView: UIStackView!
    @IBOutlet weak var vStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var accessoryImageView: UIImageView!
    @IBOutlet weak var accessoryLabel: UILabel!
    
    @IBOutlet weak var labelStackView: UIStackView!
    @IBOutlet weak var alertLabel: UILabel!
    
    @IBInspectable var text: String? {
        get{
            return titleLabel.text
        }
        set{
            titleLabel.text = newValue
        }
    }
    @IBInspectable var placeholder: String?{
        get{
//            let textField: UITextField! = filed as? UITextField
            return  textField.placeholder ?? ""
        }
        set{
            textField.placeholder = newValue
        }
    }
    @IBInspectable var secureTextEntry: Bool{
        get{
            return  textField.isSecureTextEntry
        }
        set{
            textField.isSecureTextEntry = newValue
        }
    }
    @IBInspectable var keyboardNumberPad: Bool{
        get{
            return  textField.keyboardType == .numberPad
        }
        set{
            textField.keyboardType = newValue ? .numberPad : .default
        }
    }
    
    @IBInspectable
    var isValidation: Bool = false
    
    @IBInspectable
    var usedAccessoryLabel: Bool = false
    
    //?? didsetㅇ ㅙ 한거지
    var delegate: InputStackViewDelegate?
//    {
//        didSet {
//            textFieldDidChangeSelection(textField)
//        }
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
        setAttribute()
    }
    
    override func layoutSubviews() {
        accessoryLabel.isHidden = usedAccessoryLabel == false
    }
    
    func xibSetup() {
        let bundle = Bundle(for: InputStackView.self)
        bundle.loadNibNamed("InputStackView", owner: self, options: nil)
        
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    private func setAttribute(){
        textField.delegate = self
                
        hStackView.layer.cornerRadius = 5
        hStackView.layer.borderWidth = 1
        hStackView.layer.borderColor = UIColor.lightGray.cgColor
        
        clearButton.isHidden = true
        accessoryImageView.isHidden = true
    }
    
    @IBAction private func textFieldEditingChanged(_ sender: UITextField) {
        clearButton.isHidden = textField.text?.isEmpty == true
    }
    
    @IBAction private func accessoryButtonTap(_ sender: UIButton) {
        textField.text = ""
        textField.sendActions(for: .editingChanged)
    }
    
    func setInvalidData(_ text: String){
        hStackView.layer.borderColor = UIColor.red.cgColor
        
        titleLabel.textColor = .red
        
        accessoryImageView.image = .init(systemName: "exclamationmark.circle.fill")
        accessoryImageView.tintColor = .red
        accessoryImageView.isHidden = false
        
        alertLabel.text = text
        alertLabel.textColor = .red
        labelStackView.isHidden = false
    }
    
    func setValidData(_ text: String){
        hStackView.layer.borderColor = UIColor.systemBlue.cgColor
        
        titleLabel.textColor = .systemBlue
        
        accessoryImageView.image = .init(systemName: "checkmark")
        accessoryImageView.tintColor = .systemBlue
        accessoryImageView.isHidden = false
        
        alertLabel.text = text
        alertLabel.textColor = .systemBlue
        labelStackView.isHidden = false
    }
}

extension InputStackView: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        clearButton.isHidden = textField.text?.isEmpty == true
        hStackView.layer.borderColor = UIColor.black.cgColor
        titleLabel.textColor = .darkGray
        accessoryImageView.isHidden = true
        
        if isValidation == false{
            labelStackView.isHidden = true
        }
        delegate?.inputTextFieldDidBeginEditing?(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        clearButton.isHidden = true
        
        if isValidation == false{
            hStackView.layer.borderColor = UIColor.systemGray.cgColor
//            titleLabel.textColor = .darkGray
        }
        delegate?.inputTextFieldDidEndEditing?(textField)
    }
        
    func textFieldDidChangeSelection(_ textField: UITextField) {
        delegate?.inputTextFieldDidChangeSelection?(textField)
    }
        
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return delegate?.inputTextField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }
}
