//
//  PhotoMainVC.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/12/5.
//

import UIKit

class PhotoMainVC: NotificationVC {
    
    @IBOutlet var view_title: UIView!
    
    @IBOutlet var view_choose: UIView!
    @IBOutlet var label_choose: UILabel!
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionView_flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet var stackView_menu: UIStackView!
    
    private var isChoose: Bool = false { didSet {
        label_choose.text = isChoose ? "取消" : "選取"
        collectionView.reloadData()
        stackView_menu.isHidden = !isChoose
    }}
    
    private var choosePhoto = [Int]()
    private var photoData = UserDefaultManager.getPhoto()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        componentsInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    }
    
    private func collectionViewInit() {
        collectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        collectionView_flowLayout.minimumLineSpacing = 10
        collectionView_flowLayout.minimumInteritemSpacing = 10
        collectionView_flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView_flowLayout.itemSize = CGSize(width: (AppWidth - 30) / 3, height: (AppWidth - 30) / 3)
    }
    
    @objc private func chooseTapped() {
        isChoose.toggle()
        
        let parentVC = parent as? ViewController
        parentVC?.useCollection(isUse: !isChoose)
        
        guard !isChoose else { return }
        choosePhoto.removeAll()
    }
}

extension PhotoMainVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoData.count + (isChoose ? 0 : 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? PhotoCollectionViewCell else { return PhotoCollectionViewCell() }
        if !photoData.isEmpty, indexPath.row < photoData.count {
            cell.setCell(data: photoData[indexPath.row], isPlus: false)
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
                cell?.tagPhoto(isTag: false)
                break
            }
            
            if !isTag {
                choosePhoto.append(indexPath.row)
                cell?.tagPhoto(isTag: true)
            }
            
        } else {
            if indexPath.row >= photoData.count {
                navigationController?.pushViewController(NewPhotoVC(), animated: true)
            } else {
                
            }
        }
    }
}
