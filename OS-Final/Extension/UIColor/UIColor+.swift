//
//  UIColor+.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/12/6.
//

import UIKit

/// 命名規則：顏色_色碼_alpha*100 ex: 灰色 #444343 0.8 = gray_444343_80

extension UIColor {
    
    // MARK: 白色
    static var white_FFFFFF: UIColor { return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) }
    static var white_FFFFFF_0: UIColor { return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0) }
}
