//
//  UIApplication+.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/12/12.
//

import Foundation
import UIKit

extension UIApplication {
    
    static var VC: UIViewController? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
        } else {
            return UIApplication.shared.keyWindow?.rootViewController
        }
    }
    
    class func getTopViewController(base: UIViewController? = VC) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
            
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)
            
        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
    
    
    class func getRootViewController(base: UIViewController? = VC) -> UIViewController? {
        if let nav = base as? UINavigationController {
            let rootVC = nav.viewControllers.first!
            return rootVC
        }
        return base
    }
}
