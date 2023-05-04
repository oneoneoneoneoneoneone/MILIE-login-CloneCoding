//
//  UISheetPresentationController+.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/05/05.
//

import Foundation
import UIKit

extension UISheetPresentationController{
    
    func setCustomFixed(){
        //크기
        detents = [.medium()]
        //무조건 싯트 아래 어둡게
        largestUndimmedDetentIdentifier = .none
        //크기확장X
        prefersScrollingExpandsWhenScrolledToEdge = false
        //아래 고정
        prefersEdgeAttachedInCompactHeight = true
        //너비 맞춤
        widthFollowsPreferredContentSizeWhenEdgeAttached = true
        preferredCornerRadius = 40
    }
}
