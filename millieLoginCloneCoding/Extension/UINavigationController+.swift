//
//  NavigationControllerView.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/18.
//

import UIKit

extension UINavigationController{
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.navigationBar.tintColor = .black
        self.navigationBar.topItem?.backButtonTitle = ""
    }
}
