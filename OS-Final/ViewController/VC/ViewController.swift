//
//  ViewController.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/11/25.
//

import UIKit

class ViewController: NotificationVC {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionView_flowLayout: UICollectionViewFlowLayout!
    
    private var barCount: Int = 3
    
    static var selectIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        componentsInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let isRootVC: Bool = (navigationController?.viewControllers.last is ViewController)
        navigationController?.setNavigationBarHidden(isRootVC, animated: false)
    }
    
    private func componentsInit() {
        collectionViewInit()
    }
    
    private func collectionViewInit() {
        collectionView.register(UINib(nibName: "BarCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        collectionView_flowLayout.minimumLineSpacing = 0
        collectionView_flowLayout.minimumInteritemSpacing = 0
        collectionView_flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    private func setPageView(page: Int, animated: Bool) {
        ViewController.selectIndex = page
        collectionView.reloadData()
        UIView.setAnimationsEnabled(animated)
    }
    
    internal func scroll(to page: Int, animated: Bool) {
        DispatchQueue.main.async {
            self.scrollView.setContentOffset(CGPoint(x: CGFloat(page) * AppWidth, y: 0), animated: animated)
            self.setPageView(page: page, animated: animated)
        }
    }
    
    /// 當各介面在執行功能，可保險鎖住根目錄。
    internal func useCollection(isUse: Bool = true) {
        collectionView.isUserInteractionEnabled = isUse
    }
}

extension ViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return barCount
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:  AppWidth / CGFloat(barCount), height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? BarCollectionViewCell else { return BarCollectionViewCell() }
        cell.setCell(index: indexPath.row, isSelected: indexPath.row == ViewController.selectIndex)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard ViewController.selectIndex != indexPath.row else { return }
        scroll(to: indexPath.row, animated: true)
    }
}
