//
//  AlbumCollectionViewCell.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/12/6.
//

import UIKit
import SDWebImage

class AlbumCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView_cover: UIImageView!
    @IBOutlet var imageView_cover_height: NSLayoutConstraint!
    
    @IBOutlet var label_albumName: UILabel!
    @IBOutlet var label_albumCount: UILabel!
    
    @IBOutlet var view_gray: UIView!
    @IBOutlet var imageView_remove: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        componentsInit()
    }
    
    func setCell(data: albumDataInfo, isRemove: Bool) {
        imageView_cover.image = UIImage(data: data.image)
        label_albumName.text = data.title
        label_albumCount.text = "\(data.total)"
        
        view_gray.isHidden = !isRemove
        imageView_remove.isHidden = !isRemove
    }
    
    private func componentsInit() {
        imageView_cover_height.constant = AppWidth / 2 - 15 - 10 - 10
    }
}
