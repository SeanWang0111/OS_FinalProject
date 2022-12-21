//
//  UIBarButtonItem+.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/12/21.
//

import Foundation
import UIKit

extension UIBarButtonItem {
    
    convenience init(title: String, titleColor: UIColor = .black, borderColor: UIColor = .clear, target: Any?, action: Selector) {
        let btn = UIButton(type: .custom)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(titleColor, for: .normal)
        btn.setTitleColor(.lightGray, for: .highlighted)
        btn.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = borderColor.cgColor
        btn.layer.cornerRadius = 5
        btn.addTarget(target, action: action, for: .touchUpInside)
        self.init(customView: btn)
    }
}
