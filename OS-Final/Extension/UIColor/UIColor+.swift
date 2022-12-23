//
//  UIColor+.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/12/6.
//

import UIKit

/// 命名規則：顏色_色碼_alpha*100 ex: 灰色 #444343 0.8 = gray_444343_80

extension UIColor {
    
    // MARK: 黑色
    static var black_000000_25: UIColor { return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.25) }
    static var black_4D4D4D: UIColor { return #colorLiteral(red: 0.3019607843, green: 0.3019607843, blue: 0.3019607843, alpha: 1) }
    static var black_7D7D7D: UIColor { return #colorLiteral(red: 0.4901960784, green: 0.4901960784, blue: 0.4901960784, alpha: 1) }
    static var black_BCBCBC: UIColor { return #colorLiteral(red: 0.737254902, green: 0.737254902, blue: 0.737254902, alpha: 1) }
    
    // MARK: 藍色
    static var blue_0A84FF: UIColor { return #colorLiteral(red: 0.03921568627, green: 0.5176470588, blue: 1, alpha: 1) }
    static var blue_406682: UIColor { return #colorLiteral(red: 0.2509803922, green: 0.4, blue: 0.5098039216, alpha: 1) }
    static var blue_C1E3FC: UIColor { return #colorLiteral(red: 0.7568627451, green: 0.8901960784, blue: 0.9882352941, alpha: 1) }
    
    // MARK: 白色
    static var white_FFFFFF: UIColor { return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) }
    static var white_FFFFFF_0: UIColor { return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0) }
    static var white_FFFFFF_50: UIColor { return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5) }
}
