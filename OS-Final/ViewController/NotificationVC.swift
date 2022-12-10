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
    }
    
    private func deInitNavigationItems() {
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil
    }
    
    private func deInitNotifications() {
        // 這裡把廣播一個一個去做刪除 而不使用NotificationCenter.default.removeObserver(self)來全部刪除
        // 因為有些頁面有自己的廣播必須保留不要被刪除 例如:videoListVC的廣播
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("APINotification"), object: nil)
    }
    
    /// API監聽處理
    @objc func APINotificationReceiver(notification: NSNotification) {
        DispatchQueue.main.async {
        }
    }
    
    @objc func backBarItemClick() {
        navigationController?.popViewController(animated: true)
    }
}
