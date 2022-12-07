//
//  AlbumMainVC.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/12/6.
//

import UIKit

class AlbumMainVC: UIViewController {
    
    @IBOutlet var view_title: UIView!
    
    @IBOutlet var view_edit: UIView!
    @IBOutlet var label_edit: UILabel!
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionView_flowLayout: UICollectionViewFlowLayout!
    
    private var isRemove: Bool = false { didSet {
        label_edit.text = isRemove ? "完成" : "編輯"
        collectionView.reloadData()
    }}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        componentsInit()
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
    }
    
    private func collectionViewInit() {
        collectionView.register(UINib(nibName: "AlbumCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        collectionView_flowLayout.minimumLineSpacing = 10
        collectionView_flowLayout.minimumInteritemSpacing = 10
        collectionView_flowLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    @objc private func editTapped() {
        isRemove.toggle()
    }
}

extension AlbumMainVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? AlbumCollectionViewCell else { return AlbumCollectionViewCell() }
        cell.setCell(isRemove: isRemove)
        return cell
    }
}
