//
//  NewPhotoVC.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/12/10.
//

import UIKit
import SDWebImage

class NewPhotoVC: NotificationVC {
    
    @IBOutlet var view_text: UIView!
    @IBOutlet var textView: UITextView!
    @IBOutlet var view_search: UIView!
    @IBOutlet var view_cross: UIView!
    
    @IBOutlet var view_image: UIView!
    @IBOutlet var imageView_photo: UIImageView!
    
    @IBOutlet var view_left: UIView!
    @IBOutlet var view_right: UIView!
    
    @IBOutlet var view_imageCount: UIView!
    @IBOutlet var label_imageCount: UILabel!
    
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet var view_action: UIView!
    @IBOutlet var view_remove: UIView!
    @IBOutlet var view_import: UIView!
    
    @IBOutlet var view_loading: UIView!
    @IBOutlet var imageView_loading: SDAnimatedImageView!
    
    private lazy var label_placeHolder: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 5, y: 10, width: textView.bounds.width - 5, height: 20)
        label.text = "Instagram or Twitter"
        label.font = UIFont(name: "System", size: 16)
        label.textColor = .black_7D7D7D
        label.textAlignment = NSTextAlignment.left
        label.isHidden = !textView.text.isEmpty
        return label
    }()
    
    private var photoData: [photoDataInfo] = UserDefaultManager.getPhoto()
    private var messageData = [MediaGetterRes.Messages]()
    
    private var index: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        componentsInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        // 滑動返回
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func APINotificationReceiver(notification: NSNotification) {
        super.APINotificationReceiver(notification: notification)
        DispatchQueue.main.async {
            if let res = notification.object as? MediaGetterRes {
                self.handleMediaGetter(res: res)
            }
        }
    }
    
    override func APIFailedNotificationReceiver(notification: NSNotification) {
        super.APIFailedNotificationReceiver(notification: notification)
        DispatchQueue.main.async {
            self.view.makeToast("搜尋失敗")
        }
    }
    
    private func componentsInit() {
        title = "新增"
        
        viewInit()
        textViewInit()
        setKillKeyBoardTapGR(tap: 1)
        pageControlInit()
    }
    
    private func viewInit() {
        view_text.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        
        view_cross.isHidden = true
        view_cross.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(crossTapped)))
        
        view_search.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        view_search.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(searchTapped)))
        
        view_left.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(leftTapped)))
        view_right.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rightTapped)))
        
        view_image.isHidden = true
        view_action.isHidden = true
        
        view_remove.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeTapped)))
        view_import.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(importTapped)))
    }
    
    private func textViewInit() {
        textView.text = ""
        textView.addSubview(label_placeHolder)
        textView.bringSubviewToFront(label_placeHolder)
        textView.delegate = self
    }
    
    private func setKillKeyBoardTapGR(tap: Int = 1) {
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(killKeyboard))
        tapGR.numberOfTapsRequired = tap
        tapGR.delegate = self
        view.addGestureRecognizer(tapGR)
    }
    
    private func pageControlInit() {
        pageControl.isHidden = true
        pageControl.numberOfPages = 1
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .black_BCBCBC
    }
    
    private func handleMediaGetter(res: MediaGetterRes) {
        guard let messages = res.messages else { return }
        messageData = messages
        
        view_image.isHidden = false
        view_action.isHidden = false
        
        view_left.isUserInteractionEnabled = messages.count > 1
        view_right.isUserInteractionEnabled = messages.count > 1
        
        view_imageCount.isHidden = messages.count < 2
        label_imageCount.text = "\(messages.count)"
        index = 0
        pageControl.isHidden = false
        pageControl.numberOfPages = messages.count
        pageControl.currentPage = 0
        
        imageView_photo.sd_setImage(with: URL(string: messages[index].previewImageUrl))
    }
    
    private func typeChange(urlStr: String) -> Data {
        guard let urlStr: URL = URL(string: urlStr), let data: Data = try? Data(contentsOf: urlStr) else { return Data() }
        return data
    }
    
    @objc private func crossTapped() {
        textView.text = ""
        view_cross.isHidden = true
        label_placeHolder.isHidden = false
    }
    
    @objc private func searchTapped() {
        view.endEditing(true)
        guard !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            view.makeToast("請輸入內容")
            return
        }
        guard let urlStr: String = textView.text, let escapedString: String = "\(urlStr)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        APIManager.doMediaGetter(url: escapedString)
    }
    
    @objc private func leftTapped() {
        index = index - 1 < 0 ? messageData.count - 1 : index - 1
        imageView_photo.sd_setImage(with: URL(string: messageData[index].previewImageUrl))
        pageControl.currentPage = index
    }
    
    @objc private func rightTapped() {
        index = index + 1 >= messageData.count ? 0 : index + 1
        imageView_photo.sd_setImage(with: URL(string: messageData[index].previewImageUrl))
        pageControl.currentPage = index
    }
    
    @objc private func removeTapped() {
        showChooseDialogVC(title: .removeSearch)
    }
    
    @objc private func importTapped() {
        showChooseDialogVC(title: .downLoadToApp)
    }
    
    @objc private func killKeyboard() {
        let topVCView = UIApplication.getTopViewController()?.view
        topVCView?.endEditing(true)
    }
}

extension NewPhotoVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        label_placeHolder.isHidden = !textView.text.isEmpty
        view_cross.isHidden = textView.text.isEmpty
    }
}

extension NewPhotoVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}

extension NewPhotoVC: ChooseDialogVCDelegate {
    func confirmClickWith(title: Titles) {
        removePresented() {
            switch title {
            case .downLoadToApp:
                let mainQueue = DispatchQueue.main
                let secQueue = DispatchQueue.global()
                let groupQueue = DispatchGroup()
                self.view_loading.isHidden = false
                self.imageView_loading.image = SDAnimatedImage(named: "loading.gif")
                self.imageView_loading.startAnimating()
                
                for list in self.messageData {
                    secQueue.async(group: groupQueue) {
                        let detail = photoDataInfo(type: list.type, previewImageUrl: list.previewImageUrl, originalContentUrl: list.originalContentUrl, image: self.typeChange(urlStr: list.previewImageUrl), video: list.type == "image" ? Data() : self.typeChange(urlStr: list.originalContentUrl))
                        self.photoData.append(detail)
                    }
                }
                groupQueue.notify(queue: mainQueue) {
                    UserDefaultManager.setPhoto(self.photoData)
                    self.view_loading.isHidden = true
                    self.imageView_loading.stopAnimating()
                    self.view.makeToast("匯入成功")
                }
                
            case .removeSearch:
                self.textView.text = ""
                self.view_cross.isHidden = true
                self.label_placeHolder.isHidden = false
                self.view_image.isHidden = true
                self.pageControl.isHidden = true
                self.view_action.isHidden = true
                
            default:
                break
            }
        }
    }
}
