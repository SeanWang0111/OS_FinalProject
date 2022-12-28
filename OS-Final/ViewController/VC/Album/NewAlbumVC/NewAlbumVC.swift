//
//  NewAlbumVC.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/12/20.
//

import UIKit

@objc protocol NewAlbumVCDelegate: AnyObject {
    func edited(titleStr: String, cover: Data)
}

class NewAlbumVC: NotificationVC {
    
    @IBOutlet var textView: UITextView!
    @IBOutlet var view_cross: UIView!
    
    @IBOutlet var imageView_photo: UIImageView!
    
    private var photoData = [photoDataInfo]()
    private var albumData: [albumDataInfo] = UserDefaultManager.getAlbum()
    private var mode: Mode = .new
    
    private var albumTitle: String = ""
    private var albumImage = Data()
    
    weak var delegate: NewAlbumVCDelegate?
    
    private lazy var label_placeHolder: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 5, y: 10, width: textView.bounds.width - 5, height: 20)
        label.text = "請輸入名稱"
        label.font = UIFont(name: "System", size: 16)
        label.textColor = .black_7D7D7D
        label.textAlignment = NSTextAlignment.left
        label.isHidden = !textView.text.isEmpty
        return label
    }()
    
    enum Mode {
        case new
        case edit
    }
    
    convenience init(mode: Mode, photoData: [photoDataInfo], title: String = "", cover: Data = Data() ) {
        self.init()
        self.mode = mode
        self.photoData = photoData
        albumTitle = title
        albumImage = cover
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        componentsInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "確認", titleColor: .blue_0A84FF, target: self, action: #selector(finishTapped))
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        // 滑動返回
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    private func componentsInit() {
        title = "\(mode == .new ? "新增" : "編輯")相簿"
        if mode == .edit, let image: UIImage = UIImage(data: albumImage) {
            imageView_photo.image = image
        } else {
            imageInit()
        }
        
        imageView_photo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(photoTapped)))
        textViewInit()
        setKillKeyBoardTapGR(tap: 1)
    }
    
    private func textViewInit() {
        textView.text = albumTitle
        textView.addSubview(label_placeHolder)
        textView.bringSubviewToFront(label_placeHolder)
        textView.delegate = self
    }
    
    private func imageInit(index: Int = 0) {
        if let image: UIImage = UIImage(data: photoData[index].image) {
            imageView_photo.image = image
            albumImage = photoData[index].image
        } else {
            if let urlStr: URL = URL(string: photoData[index].previewImageUrl), let data: Data = try? Data(contentsOf: urlStr) {
                imageView_photo.sd_setImage(with: urlStr)
                albumImage = data
            }
        }
    }
    
    private func setKillKeyBoardTapGR(tap: Int = 1) {
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(killKeyboard))
        tapGR.numberOfTapsRequired = tap
        tapGR.delegate = self
        view.addGestureRecognizer(tapGR)
    }
    
    @objc private func photoTapped() {
        let VC = OverViewVC(mode: .AlbumCover, photoData: photoData)
        VC.delegate = self
        navigationController?.pushViewController(VC, animated: true)
    }
    
    @objc private func finishTapped() {
        view.endEditing(true)
        guard !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            view.makeToast("請輸入名稱")
            return
        }
        
        guard let urlStr: String = textView.text else { return }
        switch mode {
        case .new:
            albumData.append(albumDataInfo(image: albumImage, title: urlStr, total: photoData.count, photoData: photoData))
            UserDefaultManager.setAlbum(albumData)
            UserDefaultManager.setReloadData(true)
            view.makeToast("新增完成")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                guard let rootVC = UIApplication.getRootViewController() as? ViewController else { return }
                rootVC.scroll(to: 1, animated: false)
                rootVC.navigationController?.setViewControllers([rootVC], animated: false)
            }
            
        case .edit:
            view.makeToast("編輯完成")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.delegate?.edited(titleStr: urlStr, cover: self.albumImage)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc private func crossTapped() {
        textView.text = ""
        view_cross.isHidden = true
        label_placeHolder.isHidden = false
    }
    
    @objc private func killKeyboard() {
        let topVCView = UIApplication.getTopViewController()?.view
        topVCView?.endEditing(true)
    }
}

extension NewAlbumVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        label_placeHolder.isHidden = !textView.text.isEmpty
        view_cross.isHidden = textView.text.isEmpty
    }
}

extension NewAlbumVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}

extension NewAlbumVC: OverViewVCDelegate {
    func coverChange(index: Int) {
        imageInit(index: index)
    }
}
