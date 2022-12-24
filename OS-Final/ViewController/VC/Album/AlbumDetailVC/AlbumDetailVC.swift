//
//  AlbumDetailVC.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/12/23.
//

import UIKit

class AlbumDetailVC: NotificationVC {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionView_flowLayout: UICollectionViewFlowLayout!
    
    private var albumData: albumDataInfo? = nil
    private var photoData = [photoDataInfo]()
    
    private var isChoose: Bool = false
    private var choosePhoto = [Int]()
    
    convenience init(albumData: albumDataInfo) {
        self.init()
        self.albumData = albumData
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
    }
    
    private func componentsInit() {
        if let data = albumData {
            title = data.title
            photoData = data.photoData
        }
        
        collectionViewInit()
    }
    
    private func collectionViewInit() {
        collectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        collectionView_flowLayout.minimumLineSpacing = 10
        collectionView_flowLayout.minimumInteritemSpacing = 10
        collectionView_flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView_flowLayout.itemSize = CGSize(width: (AppWidth - 30) / 3, height: (AppWidth - 30) / 3)
    }
    
    @objc private func moreTapped() {
        
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
                navigationController?.pushViewController(NewPhotoVC(), animated: true)
            } else {
                let VC = PhotoDetailVC(photoData: photoData, index: indexPath.row, mode: .album)
                VC.delegate = self
                navigationController?.pushViewController(VC, animated: true)
            }
        }
    }
}

extension AlbumDetailVC: PhotoDetailVCDelegate {
    func needReload() {
    }
}

extension AlbumDetailVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}
