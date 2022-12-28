//
//  PhotoDetailVC.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/12/14.
//

import UIKit
import AVFoundation
import Photos

@objc protocol PhotoDetailVCDelegate: AnyObject {
    func isAlbumDetail()
}

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
    @IBOutlet var label_page: UILabel!
    
    // 影片時間進度
    @IBOutlet var view_time: UIView!
    @IBOutlet var label_nowTime: UILabel!
    @IBOutlet var progress_video: UIProgressView!
    @IBOutlet var label_endTime: UILabel!
    
    // 下方選單區塊
    @IBOutlet var view_menu: UIView!
    @IBOutlet var view_newFolder: UIView!
    @IBOutlet var view_play: UIView!
    @IBOutlet var imageView_play: UIImageView!
    @IBOutlet var view_downLoad: UIView!
    @IBOutlet var view_trash: UIView!
    
    @IBOutlet var view_bottom: UIView!
    
    private var photoData = [photoDataInfo]()
    private var albumData: [albumDataInfo] = UserDefaultManager.getAlbum()
    private var photoIndex: Int = 0 { didSet {
        label_page.text = "\(photoIndex + 1) / \(photoData.count)"
    }}
    
    private var mode: Mode = .photo
    private var isReloadData: Bool = false
    
    private var isHiddenBar: Bool = false { didSet {
        view_top.isHidden = isHiddenBar
        view_bar.isHidden = isHiddenBar
        view_time.isHidden = photoData[photoIndex].type == "video" ? isHiddenBar : true
        view_menu.isHidden = isHiddenBar
        view_bottom.isHidden = isHiddenBar
    }}
    
    // 影片參數
    private var player: AVPlayer?
    private var isFirstPlay: Bool = true
    private var isPlay: Bool = false
    private var timer_video: Timer?
    private var duration = CMTime()
    
    private var albumDetailCount: Int = 0
    
    weak var delegate: PhotoDetailVCDelegate?
    
    enum Mode {
        case photo
        case album
    }
    
    convenience init(photoData: [photoDataInfo], index: Int, mode: Mode = .photo) {
        self.init()
        self.photoData = photoData
        // 為相簿設置
        albumDetailCount = photoData.count
        photoIndex = index
        self.mode = mode
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        componentsInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        // 滑動返回
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        closeTimer()
        guard mode == .album, photoData.count != albumDetailCount else { return }
        UserDefaultManager.setAlbumNew(photoData)
        delegate?.isAlbumDetail()
    }
    
    private func componentsInit() {
        label_page.text = "\(photoIndex + 1) / \(photoData.count)"
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
        
        view_newFolder.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(newFolderTapped)))
        view_play.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(videoPlayTapped)))
        view_downLoad.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(downLoadTapped)))
        view_trash.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(trashTapped)))
    }
    
    private func imageInit() {
        let frontIndex: Int = photoIndex - 1 < 0 ? photoData.count - 1 : photoIndex - 1
        let nextIndex: Int = photoIndex + 1 >= photoData.count ? 0 : photoIndex + 1
        
        if let image = UIImage(data: photoData[frontIndex].image) {
            imageView_photo1.image = image
        } else {
            imageView_photo1.sd_setImage(with: URL(string: photoData[frontIndex].previewImageUrl))
        }
        
        if let image = UIImage(data: photoData[photoIndex].image) {
            imageView_photo2.image = image
        } else {
            imageView_photo2.sd_setImage(with: URL(string: photoData[photoIndex].previewImageUrl))
        }
        
        if let image = UIImage(data: photoData[nextIndex].image) {
            imageView_photo3.image = image
        } else {
            imageView_photo3.sd_setImage(with: URL(string: photoData[nextIndex].previewImageUrl))
        }
    }
    
    // 預覽圖片設定
    private func presetImageInit() {
        let frontIndex: Int = photoIndex - 1 < 0 ? photoData.count - 1 : photoIndex - 1
        let nextIndex: Int = photoIndex + 1 >= photoData.count ? 0 : photoIndex + 1
        
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
        view_play.isHidden = photoData[photoIndex].type == "image"
        view_time.isHidden = photoData[photoIndex].type == "image"
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
        closeTimer()
        isPlay = false
        
        guard photoData[photoIndex].type == "video" else { return }
        // 應急 擋住多餘的影片
        let blackView = UIView()
        blackView.backgroundColor = .black
        blackView.frame = CGRect(x: 0, y: 0, width: view_player.bounds.width, height: view_player.bounds.height)
        view_player.addSubview(blackView)
        
        let remoteURL = NSURL(string: photoData[photoIndex].originalContentUrl)
        player = AVPlayer(url: remoteURL! as URL)
        duration = AVPlayerItem(url: remoteURL! as URL).asset.duration
        setVideoProgress(endTime: Int(CMTimeGetSeconds(duration)))
        let layer = AVPlayerLayer(player: player)
        layer.frame = view_player.bounds
        view_player.layer.addSublayer(layer)
    }
    
    private func setVideoProgress(nowTime: Int = 0, endTime: Int) {
        let needHour: Bool = endTime / 3600 != 0
        label_nowTime.text = showTime(needHour: needHour, time: nowTime)
        label_endTime.text = showTime(needHour: needHour, time: endTime)
        DispatchQueue.main.async {
            self.progress_video.progress = Float(nowTime) / Float(endTime)
        }
    }
    
    // 時間轉換
    private func showTime(needHour: Bool, time: Int) -> String {
        let hour: Int = time / 3600
        let min: Int = time / 60
        let sec: Int = time % 60
        return needHour ? String(format: "%02d:%02d:%02d", hour, min, sec) : String(format: "%02d:%02d", min, sec)
    }
    
    // 設定預覽圖左邊還右邊圖示
    private func setPreset(isLeft: Bool) {
        stackView_preset.isHidden = false
        imageView_preset1.isHidden = isLeft
        imageView_preset2.isHidden = !isLeft
    }
    
    // 計時偵測影片時間和結束狀態
    private func setTimer() {
        guard timer_video == nil else { return }
        timer_video = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer) in
            self.setVideoProgress(nowTime: Int(self.player?.currentTime().seconds ?? 0), endTime: Int(CMTimeGetSeconds(self.duration)))
            guard self.player?.currentTime().seconds == CMTimeGetSeconds(self.duration) else { return }
            self.player?.seek(to: CMTime(value: 0, timescale: 1))
            self.player?.pause()
            self.isPlay = false
            self.imageView_play.image = UIImage(systemName: "play.fill")
        })
    }
    
    private func closeTimer() {
        guard timer_video != nil else { return }
        timer_video?.invalidate()
        timer_video = nil
    }
    
    @objc private func newFolderTapped() {
        showListDialog(albumData: albumData)
    }
    
    @objc private func videoPlayTapped() {
        switch player?.status {
        case .readyToPlay:
            if isFirstPlay {
                view_player.isHidden = false
                setTimer()
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
        if photoData[photoIndex].type == "image" {
            if let image: UIImage = UIImage(data: photoData[photoIndex].image) {
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
                let urlData: NSData = NSData(data: self.photoData[self.photoIndex].video)
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
        switch mode {
        case .photo:
            showChooseDialogVC(title: .removePhoto)
            
        case .album:
            guard photoData.count != 1 else {
                view.makeToast("相簿至少一張圖片")
                return
            }
            showChooseDialogVC(title: .removePhoto)
        }
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
            photoIndex = photoIndex - 1 < 0 ? photoData.count - 1 : photoIndex - 1
            setPreset(isLeft: false)
            switchInit()
        } else if currentPage == 2 {
            photoIndex = photoIndex + 1 >= photoData.count ? 0 : photoIndex + 1
            setPreset(isLeft: true)
            switchInit()
        }
    }
}

extension PhotoDetailVC: ListDialogVCDelegate {
    func listDidClick(index: Int) {
        removePresented() { [self] in
            UserDefaultManager.setReloadData(true)
            
            if albumData.indices.contains(index) {
                // 匯入已有的相簿
                albumData[index].photoData.append(contentsOf: [photoData[photoIndex]])
                albumData[index].total = albumData[index].photoData.count
                UserDefaultManager.setAlbum(albumData)
                view.makeToast("匯入完成")
                
            } else {
                // 新增相簿
                navigationController?.pushViewController(NewAlbumVC(mode: .new, photoData: [photoData[photoIndex]]), animated: true)
            }
        }
    }
}

extension PhotoDetailVC: ChooseDialogVCDelegate {
    func confirmClickWith(title: Titles) {
        removePresented() { [self] in
            switch title {
            case .removePhoto:
                switch mode {
                case .photo:
                    photoData.remove(at: photoIndex)
                    UserDefaultManager.setPhoto(photoData)
                    view.makeToast("刪除成功")
                    
                    guard !photoData.isEmpty else {
                        backTapped()
                        return
                    }
                    
                    photoIndex = photoIndex != 0 ? photoIndex - 1 : 0
                    componentsInit()
                    
                case .album:
                    photoData.remove(at: photoIndex)
                    view.makeToast("刪除成功")
                    
                    guard !photoData.isEmpty else {
                        backTapped()
                        return
                    }
                    
                    photoIndex = photoIndex != 0 ? photoIndex - 1 : 0
                    componentsInit()
                }
                
            default:
                break
            }
        }
    }
}

