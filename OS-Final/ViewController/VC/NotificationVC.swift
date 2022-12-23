//
//  NotificationVC.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/12/9.
//

import UIKit
import SDWebImage
import Toast_Swift

class NotificationVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar()
        notificationsInit()
    }
    
    /// 一定要放在viewWillAppear之後，不可以放在viewDidLoad！不然從其他頁面返回時，返回按鈕會被重置
    private func setNavigationBar() {
        // Set navigation bar color
        navigationController?.navigationBar.tintColor = .black
        // Remove back title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        
        let backButton = setBackBarItem()
        backButton.addTarget(self, action: #selector(backBarItemClick), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.backBarButtonItem?.title = ""
        navigationItem.backBarButtonItem?.tintColor = .black
    }
    
    private func notificationsInit() {
        NotificationCenter.default.addObserver(self, selector: #selector(APINotificationReceiver), name: Notification.Name("APINotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowReceiver), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideReceiver), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    private func deInitNavigationItems() {
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil
    }
    
    private func deInitNotifications() {
        // 這裡把廣播一個一個去做刪除 而不使用NotificationCenter.default.removeObserver(self)來全部刪除
        // 因為有些頁面有自己的廣播必須保留不要被刪除 例如:videoListVC的廣播
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("APINotification"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    /// 鍵盤升起
    func keyboardWillShow(duration: Double, height: CGFloat) {
        
    }
    /// 鍵盤下降
    func keyboardWillHide(duration: Double) {
        
    }
    
    func updateData() {
    }
    
    /// API監聽處理
    @objc func APINotificationReceiver(notification: NSNotification) {
        DispatchQueue.main.async {
        }
    }
    
    @objc func backBarItemClick() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc fileprivate func keyboardWillShowReceiver(notification: NSNotification) {
        let userInfo = notification.userInfo
        let keyboardFrame = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        guard let duration = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double, let size = keyboardFrame?.cgRectValue else { return }
        keyboardWillShow(duration: duration, height: size.height)
    }

    @objc fileprivate func keyboardWillHideReceiver(notification: NSNotification) {
        let userInfo = notification.userInfo
        guard let duration = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        keyboardWillHide(duration: duration)
    }
}
