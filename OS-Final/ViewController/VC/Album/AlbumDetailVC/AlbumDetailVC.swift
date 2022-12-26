//
//  AlbumDetailVC.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/12/23.
//

import UIKit
import Photos
import UICircularProgressRing
import SDWebImage

class AlbumDetailVC: NotificationVC {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionView_flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet var stackView_menu: UIStackView!
    @IBOutlet var label_selectTotal: UILabel!
    @IBOutlet var view_downLoad: UIView!
    @IBOutlet var view_trash: UIView!
    
    @IBOutlet var view_loading: UIView!
    @IBOutlet var progressRing_Loading: UICircularProgressRing!
    @IBOutlet var label_loading: UILabel!
    @IBOutlet var imageView_loading: SDAnimatedImageView!
    
    private var albumData = [albumDataInfo]()
    private var albumIndex: Int = 0
    private var photoData = [photoDataInfo]()
    
    private var isChoose: Bool = false
    private var choosePhoto = [Int]() { didSet {
        label_selectTotal.text = "已選取 \(choosePhoto.count)"
    }}
    
    private var isDetail: Bool = false
    
    convenience init(albumData: [albumDataInfo], albumIndex: Int) {
        self.init()
        self.albumData = albumData
        self.albumIndex = albumIndex
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        componentsInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(imgName: "gear", titleColor: .black, target: self, action: #selector(moreTapped))
        
        // 滑動返回
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        // 新增/編輯照片
        let newPhotoArr: [photoDataInfo] = UserDefaultManager.getAlbumNew()
        guard !newPhotoArr.isEmpty  else { return }
        if isDetail {
            photoData = newPhotoArr
            isDetail = false
        } else {
            photoData.append(contentsOf: newPhotoArr)
        }
        collectionView.reloadData()
        albumData[albumIndex].total = photoData.count
        albumData[albumIndex].photoData = photoData
        UserDefaultManager.setAlbum(albumData)
        UserDefaultManager.setReloadData(true)
        UserDefaultManager.clearAlbumNew()
        collectionView.reloadData()
    }
    
    private func componentsInit() {
        title = albumData[albumIndex].title
        photoData = albumData[albumIndex].photoData
        viewInit()
        collectionViewInit()
    }
    
    private func viewInit() {
        stackView_menu.layer.maskedCorners = [.layerMinXMinYCorner]
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
    
    private func setProgressRing(value: Int) {
        label_loading.text = "\(value) / \(choosePhoto.count)"
        progressRing_Loading.value = CGFloat(value)
    }
    
    private func downLoadFinish() {
        view.makeToast("下載成功")
        moreTapped()
        view_loading.isHidden = true
        imageView_loading.stopAnimating()
    }
    
    @objc private func moreTapped() {
        if isChoose {
            isChoose = false
            navigationItem.rightBarButtonItem = UIBarButtonItem(imgName: "gear", titleColor: .black, target: self, action: #selector(moreTapped))
            stackView_menu.isHidden = true
            choosePhoto.removeAll()
            collectionView.reloadData()
        } else {
            showAlbumSettingDialogVC()
        }
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
        guard choosePhoto.count < photoData.count else {
            view.makeToast("相簿至少一張圖片")
            return
        }
        showChooseDialogVC(title: .removePhoto)
    }
}

extension AlbumDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
                navigationController?.pushViewController(OverViewVC(mode: .newAlbum, photoData: [photoDataInfo]()), animated: true)
            } else {
                let VC = PhotoDetailVC(photoData: photoData, index: indexPath.row, mode: .album)
                VC.delegate = self
                navigationController?.pushViewController(VC, animated: true)
            }
        }
    }
}

extension AlbumDetailVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}

extension AlbumDetailVC: AlbumSettingDialogVCDelegate {
    func indexDidClick(index: Int) {
        removePresented() { [self] in
            switch index {
            case 0:
                let VC = NewAlbumVC(mode: .edit, photoData: photoData, title: albumData[albumIndex].title, cover: albumData[albumIndex].image)
                VC.delegate = self
                navigationController?.pushViewController(VC, animated: true)
                
            case 1:
                isChoose.toggle()
                navigationItem.rightBarButtonItem = UIBarButtonItem(imgName: "gear_selected", titleColor: .blue_0A84FF, target: self, action: #selector(moreTapped))
                stackView_menu.isHidden = false
                view_trash.isHidden = photoData.count <= 1
                collectionView.reloadData()
                
            case 2:
                showChooseDialogVC(title: .removeAlbum)
                
            default:
                break
            }
        }
    }
}

extension AlbumDetailVC: ChooseDialogVCDelegate {
    func confirmClickWith(title: Titles) {
        removePresented() { [self] in
            switch title {
            case .removeAlbum:
                guard albumData.indices.contains(albumIndex) else { return }
                albumData.remove(at: albumIndex)
                UserDefaultManager.setAlbum(albumData)
                view.makeToast("刪除成功")
                UserDefaultManager.setReloadData(true)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    guard let rootVC = UIApplication.getRootViewController() as? ViewController else { return }
                    rootVC.scroll(to: 1, animated: false)
                    rootVC.navigationController?.setViewControllers([rootVC], animated: false)
                }
                
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
                
                view.makeToast("刪除成功")
                collectionView.reloadData()
                albumData[albumIndex].total = photoData.count
                albumData[albumIndex].photoData = photoData
                UserDefaultManager.setAlbum(albumData)
                UserDefaultManager.setReloadData(true)
                collectionView.reloadData()
                moreTapped()
                
            default:
                break
            }
        }
    }
}

extension AlbumDetailVC: PhotoDetailVCDelegate {
    func isAlbumDetail() {
        isDetail = true
    }
}

extension AlbumDetailVC: NewAlbumVCDelegate {
    func edited(titleStr: String, cover: Data) {
        albumData[albumIndex].title = titleStr
        title = titleStr
        albumData[albumIndex].image = cover
        UserDefaultManager.setAlbum(albumData)
        UserDefaultManager.setReloadData(true)
    }
}
