//
//  SwiftHeader.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/12/6.
//

import UIKit
import Foundation

// MARK: -- A --

let AppWidth: CGFloat = UIScreen.main.bounds.width
let AppHeight: CGFloat = UIScreen.main.bounds.height

func setBackBarItem() -> UIButton {
    let imgView = UIImageView(image: UIImage(named: "back_arrow"))
    // y = 44/2/2
    imgView.frame = CGRect(x: 0, y: 11, width: imgView.frame.size.width, height: imgView.frame.size.height)
    let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 90, height: 44))
    backButton.addSubview(imgView)
    return backButton
}
