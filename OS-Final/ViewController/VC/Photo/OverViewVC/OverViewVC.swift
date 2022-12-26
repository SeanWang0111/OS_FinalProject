//
//  OverViewVC.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/12/24.
//

import UIKit

protocol OverViewVCDelegate: AnyObject {
    func coverChange(index: Int)
}

class OverViewVC: NotificationVC {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionView_flowLayout: UICollectionViewFlowLayout!
    
    private var mode: Mode = .newAlbum
    private var photoData = UserDefaultManager.getPhoto()
    private var choosePhoto = [Int]()
    
    weak var delegate: OverViewVCDelegate?
    
    enum Mode {
        case AlbumCover
        case newAlbum
    }
    
    convenience init(mode: Mode, photoData: [photoDataInfo]) {
        self.init()
        self.mode = mode
        self.photoData = photoData
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        componentsInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "確認", titleColor: .blue_0A84FF, target: self, action: #selector(finishTapped))
        
        // 滑動返回
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    private func componentsInit() {
        title = mode == .newAlbum ? "圖庫總覽" : "相簿封面"
        if mode == .newAlbum {
            photoData = UserDefaultManager.getPhoto()
        }
        collectionViewInit()
    }
    
    private func collectionViewInit() {
        collectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        collectionView_flowLayout.minimumLineSpacing = 10
        collectionView_flowLayout.minimumInteritemSpacing = 10
        collectionView_flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView_flowLayout.itemSize = CGSize(width: (AppWidth - 30) / 3 - 10, height: (AppWidth - 30) / 3 - 10)
    }
    
    @objc private func finishTapped() {
        guard !choosePhoto.isEmpty else {
            view.makeToast("尚未選擇")
            return
        }
        
        switch mode {
        case .AlbumCover:
            delegate?.coverChange(index: choosePhoto[0])
            navigationController?.popViewController(animated: true)
            
        case .newAlbum:
            var newPhotoArr = [photoDataInfo]()
            for index in choosePhoto {
                newPhotoArr.append(photoData[index])
            }
            UserDefaultManager.setAlbumNew(newPhotoArr)
            navigationController?.popViewController(animated: true)
        }
    }
}

extension OverViewVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoData.count
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
        var isTag: Bool = false
        let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell
        
        for i in 0..<choosePhoto.count where choosePhoto[i] == indexPath.row {
            isTag = true
            choosePhoto.remove(at: i)
            cell?.setCell(data: photoData[indexPath.row], isPlus: false, isTag: false)
            break
        }
        
        guard !isTag else { return }
        switch mode {
        case .AlbumCover:
            choosePhoto.removeAll()
            choosePhoto.append(indexPath.row)
            collectionView.reloadData()
            
        case .newAlbum:
            choosePhoto.append(indexPath.row)
            cell?.setCell(data: photoData[indexPath.row], isPlus: false, isTag: true)
        }
    }
}

extension OverViewVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}
