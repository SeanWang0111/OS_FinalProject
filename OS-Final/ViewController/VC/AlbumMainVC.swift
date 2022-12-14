//
//  AlbumMainVC.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/12/6.
//

import UIKit

class AlbumMainVC: NotificationVC {
    
    @IBOutlet var view_title: UIView!
    
    @IBOutlet var view_edit: UIView!
    @IBOutlet var label_edit: UILabel!
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionView_flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet var stackView_menu: UIStackView!
    @IBOutlet var view_newFolder: UIView!
    
    private var albumData: [albumDataInfo] = UserDefaultManager.getAlbum()
    private var selectIndex: Int = 0
    
    private var isRemove: Bool = false { didSet {
        label_edit.text = isRemove ? "完成" : "設定"
        collectionView.reloadData()
        stackView_menu.isHidden = !isRemove
    }}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        componentsInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard UserDefaultManager.getReloadData(), ViewController.selectIndex == 1 else { return }
        let parentVC = parent as? ViewController
        parentVC?.ReloadData()
        albumData = UserDefaultManager.getAlbum()
        collectionView.reloadData()
        UserDefaultManager.setReloadData(false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /// 新增相簿
        let newPhotoArr: [photoDataInfo] = UserDefaultManager.getAlbumNew()
        guard !newPhotoArr.isEmpty  else { return }
        let parentVC = parent as? ViewController
        parentVC?.ReloadData()
        navigationController?.pushViewController(NewAlbumVC(mode: .new, photoData: newPhotoArr), animated: true)
        UserDefaultManager.clearAlbumNew()
    }
    
    override func updateData() {
        isRemove = false
        albumData = UserDefaultManager.getAlbum()
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
        
        view_edit.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editTapped)))
        
        stackView_menu.layer.maskedCorners = [.layerMinXMinYCorner]
        view_newFolder.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(newFolderTapped)))
    }
    
    private func collectionViewInit() {
        collectionView.register(UINib(nibName: "AlbumCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        collectionView_flowLayout.minimumLineSpacing = 10
        collectionView_flowLayout.minimumInteritemSpacing = 10
        collectionView_flowLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    @objc private func editTapped() {
        isRemove.toggle()
        let parentVC = parent as? ViewController
        parentVC?.useCollection(isUse: !isRemove)
    }
    
    @objc private func newFolderTapped() {
        editTapped()
        navigationController?.pushViewController(OverViewVC(mode: .newAlbum, photoData: [photoDataInfo]()), animated: true)
    }
}

extension AlbumMainVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? AlbumCollectionViewCell, let data = albumData.getObject(at: indexPath.row) else { return AlbumCollectionViewCell() }
        cell.setCell(data: data, isRemove: isRemove)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isRemove {
            selectIndex = indexPath.row
            showChooseDialogVC(title: .removePhoto)
        } else {
            navigationController?.pushViewController(AlbumDetailVC(albumData: albumData, albumIndex: indexPath.row), animated: true)
        }
    }
}

extension AlbumMainVC: ChooseDialogVCDelegate {
    func confirmClickWith(title: Titles) {
        removePresented() { [self] in
            switch title {
            case .removePhoto:
                guard albumData.indices.contains(selectIndex) else { return }
                albumData.remove(at: selectIndex)
                selectIndex = 0
                UserDefaultManager.setAlbum(albumData)
                editTapped()
                
                let parentVC = parent as? ViewController
                parentVC?.ReloadData()
                view.makeToast("刪除成功")
                
            default:
                break
            }
        }
    }
}
