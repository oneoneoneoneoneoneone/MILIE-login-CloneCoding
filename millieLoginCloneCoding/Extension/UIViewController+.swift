//
//  UIViewController+.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/04.
//

import UIKit

extension UIViewController{
   open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
    }
}
