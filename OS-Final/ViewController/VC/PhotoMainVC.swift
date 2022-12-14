//
//  PhotoMainVC.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/12/5.
//

import UIKit
import Photos
import UICircularProgressRing
import SDWebImage

class PhotoMainVC: NotificationVC {
    
    @IBOutlet var view_title: UIView!
    
    @IBOutlet var view_choose: UIView!
    @IBOutlet var label_choose: UILabel!
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionView_flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet var view_selectTotal: UILabel!
    
    @IBOutlet var stackView_menu: UIStackView!
    @IBOutlet var view_newFolder: UIView!
    @IBOutlet var view_downLoad: UIView!
    @IBOutlet var view_trash: UIView!
    
    @IBOutlet var view_loading: UIView!
    @IBOutlet var progressRing_Loading: UICircularProgressRing!
    @IBOutlet var label_loading: UILabel!
    @IBOutlet var imageView_loading: SDAnimatedImageView!
    
    private var isChoose: Bool = false { didSet {
        label_choose.text = isChoose ? "取消" : "選取"
        collectionView.reloadData()
        stackView_menu.isHidden = !isChoose
    }}
    
    private var choosePhoto = [Int]() { didSet {
        view_selectTotal.text = "已選取 \(choosePhoto.count)"
    }}
    private var photoData: [photoDataInfo] = UserDefaultManager.getPhoto()
    private var albumData: [albumDataInfo] = UserDefaultManager.getAlbum()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        componentsInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaultManager.getReloadData(), ViewController.selectIndex == 0 {
            let parentVC = parent as? ViewController
            parentVC?.ReloadData()
            UserDefaultManager.setReloadData(false)
        }
        // 看內容 新增刷新
        guard !isChoose else { return }
        choosePhoto.removeAll()
        let parentVC = parent as? ViewController
        parentVC?.useCollection(isUse: true)
        photoData = UserDefaultManager.getPhoto()
        collectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !photoData.isEmpty {
            collectionView.scrollToItem(at: IndexPath(item: photoData.count - 1, section: 0), at: .bottom, animated: false)
        }
    }
    
    override func updateData() {
        isChoose = false
        choosePhoto.removeAll()
        albumData = UserDefaultManager.getAlbum()
        photoData = UserDefaultManager.getPhoto()
        collectionView.reloadData()
    }
    
    private func componentsInit() {
        viewInit()
        collectionViewInit()
    }
    
    private func viewInit() {
        let gradient = CAGradientLayer()
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.colors = [UIColor.white_FFFFFF.cgColor, UIColor.white_FFFFFF_0.cgColor]
        gradient.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: view_title.bounds.size.height)
        view_title.layer.insertSublayer(gradient, at: 0)
        
        view_choose.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chooseTapped)))
        
        stackView_menu.layer.maskedCorners = [.layerMinXMinYCorner]
        view_newFolder.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(newFolderTapped)))
        view_downLoad.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(downLoadTapped)))
        view_trash.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(trashTapped)))
    }
    
    private func collectionViewInit() {
        collectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        collectionView_flowLayout.minimumLineSpacing = 10
        collectionView_flowLayout.minimumInteritemSpacing = 10
        collectionView_flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView_flowLayout.itemSize = CGSize(width: (AppWidth - 30) / 3, height: (AppWidth - 30) / 3)
    }
    
    /// 依序下載圖片 / 影片
    private func downLoadPhoto(photoIndex: Int) {
        let index: Int = choosePhoto[photoIndex]
        
        // 圖片
        if photoData[index].type == "image" {
            if let image: UIImage = UIImage(data: photoData[index].image) {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
            
            setProgressRing(value: photoIndex + 1)
            if photoIndex + 1 == choosePhoto.count {
                downLoadFinish()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
                    downLoadPhoto(photoIndex: photoIndex + 1)
                }
            }
        }
        // 影片
        else {
            let galleryPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
            let filePath: String = "\(galleryPath)/nameX.mp4"

            DispatchQueue.main.async {
                let urlData: NSData = NSData(data: self.photoData[index].video)
                urlData.write(toFile: filePath, atomically: true)
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                }) { success, error in
                    DispatchQueue.main.async { [self] in
                        setProgressRing(value: photoIndex + 1)
                        if photoIndex + 1 == choosePhoto.count {
                            downLoadFinish()
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
                                downLoadPhoto(photoIndex: photoIndex + 1)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 設定下載進度
    private func setProgressRing(value: Int) {
        label_loading.text = "\(value) / \(choosePhoto.count)"
        progressRing_Loading.value = CGFloat(value)
    }
    
    private func downLoadFinish() {
        view.makeToast("下載成功")
        chooseTapped()
        view_loading.isHidden = true
        imageView_loading.stopAnimating()
    }
    
    @objc private func chooseTapped() {
        isChoose.toggle()
        
        let parentVC = parent as? ViewController
        parentVC?.useCollection(isUse: !isChoose)
        
        guard !isChoose else { return }
        choosePhoto.removeAll()
    }
    
    @objc private func newFolderTapped() {
        guard !choosePhoto.isEmpty else {
            view.makeToast("尚未選擇")
            return
        }
        showListDialog(albumData: albumData)
    }
    
    @objc private func downLoadTapped() {
        guard !choosePhoto.isEmpty else {
            view.makeToast("尚未選擇")
            return
        }
        showChooseDialogVC(title: .downLoadToAlbum)
    }
    
    @objc private func trashTapped() {
        guard !choosePhoto.isEmpty else {
            view.makeToast("尚未選擇")
            return
        }
        showChooseDialogVC(title: .removePhoto)
    }
}

extension PhotoMainVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoData.count + (isChoose ? 0 : 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? PhotoCollectionViewCell else { return PhotoCollectionViewCell() }
        if !photoData.isEmpty, indexPath.row < photoData.count {
            var isTag: Bool = false
            for i in 0..<choosePhoto.count where choosePhoto[i] == indexPath.row {
                isTag = true
                break
            }
            cell.setCell(data: photoData[indexPath.row], isPlus: false, isTag: isTag)
        } else {
            cell.setCell(urlStr: "", isPlus: true)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isChoose {
            var isTag: Bool = false
            let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell
            
            for i in 0..<choosePhoto.count where choosePhoto[i] == indexPath.row {
                isTag = true
                choosePhoto.remove(at: i)
                cell?.setCell(data: photoData[indexPath.row], isPlus: false, isTag: false)
                break
            }
            
            if !isTag {
                choosePhoto.append(indexPath.row)
                cell?.setCell(data: photoData[indexPath.row], isPlus: false, isTag: true)
            }
        } else {
            if indexPath.row >= photoData.count {
                navigationController?.pushViewController(NewPhotoVC(), animated: true)
            } else {
                navigationController?.pushViewController(PhotoDetailVC(photoData: photoData, index: indexPath.row), animated: true)
            }
        }
    }
}

extension PhotoMainVC: ChooseDialogVCDelegate {
    func confirmClickWith(title: Titles) {
        removePresented() { [self] in
            switch title {
            case .downLoadToAlbum:
                view_loading.isHidden = false
                label_loading.text = "0 / \(choosePhoto.count)"
                progressRing_Loading.value = 0
                progressRing_Loading.maxValue = CGFloat(choosePhoto.count)
                imageView_loading.image = SDAnimatedImage(named: "loading.gif")
                imageView_loading.startAnimating()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                    self.downLoadPhoto(photoIndex: 0)
                }
                
            case .removePhoto:
                // 從陣列最後往前刪除 不用擔心位置不一樣
                choosePhoto.sort(by: >)
                
                for i in 0..<self.choosePhoto.count {
                    photoData.remove(at: choosePhoto[i])
                }
                
                UserDefaultManager.setPhoto(photoData)
                view.makeToast("刪除成功")
                chooseTapped()
                collectionView.reloadData()
                
            default:
                break
            }
        }
    }
}

extension PhotoMainVC: ListDialogVCDelegate {
    func listDidClick(index: Int) {
        removePresented() { [self] in
            var newPhotoArr = [photoDataInfo]()
            for index in choosePhoto {
                newPhotoArr.append(photoData[index])
            }
            let parentVC = parent as? ViewController
            parentVC?.ReloadData()
            
            if albumData.indices.contains(index) {
                // 匯入已有的相簿
                albumData[index].photoData.append(contentsOf: newPhotoArr)
                albumData[index].total = albumData[index].photoData.count
                UserDefaultManager.setAlbum(albumData)
                view.makeToast("匯入完成")
                chooseTapped()
                collectionView.reloadData()
                
            } else {
                // 新增相簿
                isChoose = false
                navigationController?.pushViewController(NewAlbumVC(mode: .new, photoData: newPhotoArr), animated: true)
            }
        }
    }
}
