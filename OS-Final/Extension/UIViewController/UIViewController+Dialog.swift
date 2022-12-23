//
//  UIViewController+Dialog.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/12/19.
//

import UIKit

extension UIViewController {
    
    enum Animator {
        case enlarge
        case fade
        case fadeOut
        case pushFromBottom
        case pushFromLeft
    }
    
    func showChooseDialogVC(title: Titles) {
        let VC = ChooseDialogVC(title: title)
        VC.delegate = self as? ChooseDialogVCDelegate
        VC.dialogShow(vc: self)
    }
    
    func showListDialog(albumData: [albumDataInfo]) {
        let VC = ListDialogVC(albumData: albumData)
        VC.delegate = self as? ListDialogVCDelegate
        VC.dialogShow(vc: self)
    }
    
    // MARK: -- Universal --
    func removePresented(animator: Animator = .enlarge, completion: (() -> Void)? = nil) {
        guard let presented = self.presentedViewController else { return }
        presented.dialogDismiss(animator: animator, completion: completion)
    }
    
    func dialogShow(vc: UIViewController, animator: Animator = .enlarge, completion: (() -> Void)? = nil) {
        self.modalPresentationStyle = .overFullScreen
        
        switch animator {
        case .enlarge, .pushFromBottom:
            // 防止閃爍
            self.view.isHidden = true
            vc.present(self, animated: false) {
                self.view.isHidden = false
                let backgroundColor: UIColor = self.view.backgroundColor ?? .black_000000_25
                self.view.backgroundColor = .clear
                self.view.alpha = animator == .enlarge ? 0 : 1
                self.view.transform = animator == .enlarge ? CGAffineTransform(scaleX: 0.2, y: 0.2) : CGAffineTransform(translationX: 0, y: self.view.bounds.height)
                
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: animator == .enlarge ? 0.35 : 0.45 , delay: 0.0, animations: {
                    self.view.alpha = 1
                    self.view.transform = CGAffineTransform.identity
                }, completion: { _ in
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0.0) {
                        self.view.backgroundColor = backgroundColor
                    }
                })
                if let completion = completion {
                    completion()
                }
            }
            
        case .pushFromLeft:
            self.view.isHidden = true
            vc.present(self, animated: false) {
                self.view.isHidden = false
                self.view.transform = CGAffineTransform(translationX: self.view.bounds.width, y: 0)
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.45, delay: 0.0, animations: {
                    self.view.transform = CGAffineTransform.identity
                })
                if let completion = completion {
                    completion()
                }
            }
            
        case .fade:
            let transition = CATransition()
            transition.duration = 0.1
            transition.type = CATransitionType.fade
            transition.subtype = CATransitionSubtype.fromBottom
            self.view.window?.layer.add(transition, forKey: kCATransition)
            vc.present(self, animated: false) {
                self.view.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                self.view.alpha = 0
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.1, delay: 0.0, animations: {
                    self.view.alpha = 1
                    self.view.transform = CGAffineTransform.identity
                })
                if let completion = completion {
                    completion()
                }
            }
            
        case .fadeOut:
            self.view.isHidden = true
            vc.present(self, animated: false) {
                self.view.isHidden = false
                self.view.alpha = 0
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.6, delay: 0.0, animations: {
                    self.view.alpha = 1
                })
                if let completion = completion {
                    completion()
                }
            }
        }
    }
    
    func dialogDismiss(animator: Animator = .enlarge, completion: (() -> Void)? = nil) {
        switch animator {
        case .enlarge, .pushFromBottom:
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.05, delay: 0.0, animations: {
                self.view.backgroundColor = .clear
            }, completion: { _ in
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0.0, animations: {
                    self.view.transform = animator == .enlarge ? CGAffineTransform(scaleX: 0.01, y: 0.01) : CGAffineTransform(translationX: 0, y: self.view.bounds.height)
                }, completion: { _ in
                    self.dismiss(animated: false, completion: completion)
                })
            })
            
        case .pushFromLeft:
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0.0, animations: {
                self.view.transform = CGAffineTransform(translationX: self.view.bounds.width, y: 0)
            }, completion: { _ in
                self.dismiss(animated: false, completion: completion)
            })
            
        case .fade:
            let transition = CATransition()
            transition.duration = 0.25
            transition.type = CATransitionType.fade
            transition.subtype = CATransitionSubtype.fromTop
            self.view.window?.layer.add(transition, forKey: kCATransition)
            self.dismiss(animated: false, completion: completion)
            
        case .fadeOut:
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0.0, animations: {
                self.view.alpha = 0
            }, completion: { _ in
                self.dismiss(animated: false, completion: completion)
            })
        }
    }
}
