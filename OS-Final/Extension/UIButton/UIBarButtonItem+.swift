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
    
    convenience init(imgName: String, titleColor: UIColor = .black, borderColor: UIColor = .clear, target: Any?, action: Selector) {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: imgName)?.resizeImage(targetSize: CGSize(width: 21, height: 21)).tint(with: titleColor), for: .normal)
        btn.setTitleColor(titleColor, for: .normal)
        btn.setTitleColor(.lightGray, for: .highlighted)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        btn.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 5)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = borderColor.cgColor
        btn.layer.cornerRadius = 10
        btn.addTarget(target, action: action, for: .touchUpInside)
        self.init(customView: btn)
    }
}
