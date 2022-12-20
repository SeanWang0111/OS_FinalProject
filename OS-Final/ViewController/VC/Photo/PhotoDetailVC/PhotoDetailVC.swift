//
//  PhotoDetailVC.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/12/14.
//

import UIKit
import AVFoundation
import Photos

class PhotoDetailVC: UIViewController {
    
    @IBOutlet var scrollView: UIScrollView!
    
    // 圖片滑頁
    @IBOutlet var imageView_photo1: UIImageView!
    @IBOutlet var view_photo2: UIView!
    @IBOutlet var imageView_photo2: UIImageView!
    @IBOutlet var view_player: UIView!
    @IBOutlet var imageView_photo3: UIImageView!
    
    // 預設防閃爍圖片
    @IBOutlet var stackView_preset: UIStackView!
    @IBOutlet var imageView_preset1: UIImageView!
    @IBOutlet var imageView_preset2: UIImageView!
    
    // 上方區塊
    @IBOutlet var view_top: UIView!
    @IBOutlet var view_bar: UIView!
    @IBOutlet var view_back: UIView!
    
    // 下方選單區塊
    @IBOutlet var view_menu: UIView!
    @IBOutlet var view_newFolder: UIView!
    @IBOutlet var view_play: UIView!
    @IBOutlet var imageView_play: UIImageView!
    @IBOutlet var view_downLoad: UIView!
    @IBOutlet var view_trash: UIView!
    
    @IBOutlet var view_bottom: UIView!
    
    private var photoData = [photoDataInfo]()
    private var index: Int = 0
    private var mode: Mode = .photo
    
    private var isHiddenBar: Bool = false { didSet {
        view_top.isHidden = isHiddenBar
        view_bar.isHidden = isHiddenBar
        view_menu.isHidden = isHiddenBar
        view_bottom.isHidden = isHiddenBar
    }}
    
    // 影片參數
    private var player: AVPlayer?
    private var isFirstPlay: Bool = true
    private var isPlay: Bool = false
    
    enum Mode {
        case photo
        case album
    }
    
    convenience init(photoData: [photoDataInfo], index: Int) {
        self.init()
        self.photoData = photoData
        self.index = index
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        componentsInit()
    }
    
    private func componentsInit() {
        viewInit()
        presetImageInit()
        
        switchInit()
    }
    
    // 切換圖片會一同刷新的方放在一起
    private func switchInit() {
        imageInit()
        setMenu()
        setScroll()
        setPlayer()
    }
    
    private func viewInit() {
        view_back.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backTapped)))
        view_photo2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hiddenTapped)))
        
        view_play.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(videoPlayTapped)))
        view_downLoad.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(downLoadTapped)))
        view_trash.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(trashTapped)))
    }
    
    private func imageInit() {
        let frontIndex: Int = index - 1 < 0 ? photoData.count - 1 : index - 1
        let nextIndex: Int = index + 1 >= photoData.count ? 0 : index + 1
        
        if let image = UIImage(data: photoData[frontIndex].image) {
            imageView_photo1.image = image
        } else {
            imageView_photo1.sd_setImage(with: URL(string: photoData[frontIndex].previewImageUrl))
        }
        
        if let image = UIImage(data: photoData[index].image) {
            imageView_photo2.image = image
        } else {
            imageView_photo2.sd_setImage(with: URL(string: photoData[index].previewImageUrl))
        }
        
        if let image = UIImage(data: photoData[nextIndex].image) {
            imageView_photo3.image = image
        } else {
            imageView_photo3.sd_setImage(with: URL(string: photoData[nextIndex].previewImageUrl))
        }
    }
    
    // 預覽圖片設定
    private func presetImageInit() {
        let frontIndex: Int = index - 1 < 0 ? photoData.count - 1 : index - 1
        let nextIndex: Int = index + 1 >= photoData.count ? 0 : index + 1
        
        if let image = UIImage(data: photoData[frontIndex].image) {
            imageView_preset1.image = image
        } else {
            imageView_preset1.sd_setImage(with: URL(string: photoData[frontIndex].previewImageUrl))
        }
        
        if let image = UIImage(data: photoData[nextIndex].image) {
            imageView_preset2.image = image
        } else {
            imageView_preset2.sd_setImage(with: URL(string: photoData[nextIndex].previewImageUrl))
        }
    }
    
    // 設定選單
    private func setMenu() {
        view_newFolder.isHidden = mode == .album
        view_play.isHidden = photoData[index].type == "image"
    }
    
    private func setScroll() {
        DispatchQueue.main.async {
            self.scrollView.setContentOffset(CGPoint(x: CGFloat(1) * AppWidth, y: 0), animated: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                // 取消預覽圖片
                stackView_preset.isHidden = true
                imageView_preset1.isHidden = true
                imageView_preset2.isHidden = true
                presetImageInit()
            }
        }
    }
    
    // 設置影片播放
    private func setPlayer() {
        // 暫停影片 重置初始
        player?.pause()
        imageView_play.image = UIImage(systemName: "play.fill")
        view_player.isHidden = true
        isFirstPlay = true
        isPlay = false
        
        guard photoData[index].type == "video" else { return }
        let remoteURL = NSURL(string: photoData[index].originalContentUrl)
        self.player = AVPlayer(url: remoteURL! as URL)
        let layer = AVPlayerLayer(player: self.player)
        layer.frame = view_player.bounds
        view_player.layer.addSublayer(layer)
    }
    
    // 設定預覽圖左邊還右邊圖示
    private func setPreset(isLeft: Bool) {
        stackView_preset.isHidden = false
        imageView_preset1.isHidden = isLeft
        imageView_preset2.isHidden = !isLeft
    }
    
    @objc private func videoPlayTapped() {
        switch player?.status {
        case .readyToPlay:
            if isFirstPlay {
                view_player.isHidden = false
            }
            
            isPlay.toggle()
            
            isPlay ? player?.play() : player?.pause()
            imageView_play.image = UIImage(systemName: "\(isPlay ? "pause" : "play").fill")
            
        default:
            view.makeToast("Failed")
        }
    }
    
    @objc private func downLoadTapped() {
        // 圖片
        if photoData[index].type == "image" {
            if let image: UIImage = UIImage(data: photoData[index].image) {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                view.makeToast("下載成功")
            } else {
                view.makeToast("下載失敗")
            }
        }
        // 影片
        else {
            let galleryPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
            let filePath: String = "\(galleryPath)/nameX.mp4"
            
            DispatchQueue.main.async {
                let urlData: NSData = NSData(data: self.photoData[self.index].video)
                urlData.write(toFile: filePath, atomically: true)
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                }) { success, error in
                    DispatchQueue.main.async {
                        self.view.makeToast("下載\(success ? "成功" : "失敗")")
                    }
                }
            }
        }
    }
    
    @objc private func trashTapped() {
        photoData.remove(at: index)
        UserDefaultManager.setPhoto(photoData)
        view.makeToast("刪除成功")
        
        guard !photoData.isEmpty else {
            backTapped()
            return
        }
        
        index = index != 0 ? index - 1 : 0
        componentsInit()
    }
    
    @objc private func hiddenTapped() {
        isHiddenBar.toggle()
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension PhotoDetailVC: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth: CGFloat = scrollView.frameLayoutGuide.layoutFrame.size.width
        let currentPage: CGFloat = scrollView.contentOffset.x / pageWidth
        if currentPage == 0 {
            index = index - 1 < 0 ? photoData.count - 1 : index - 1
            setPreset(isLeft: false)
            switchInit()
        } else if currentPage == 2 {
            index = index + 1 >= photoData.count ? 0 : index + 1
            setPreset(isLeft: true)
            switchInit()
        }
    }
}
