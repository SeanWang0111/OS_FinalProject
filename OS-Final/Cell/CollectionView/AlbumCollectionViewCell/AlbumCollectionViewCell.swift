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
    
    func setCell(isRemove: Bool) {
        view_gray.isHidden = !isRemove
        imageView_remove.isHidden = !isRemove
    }
    
    private func componentsInit() {
        imageView_cover_height.constant = AppWidth / 2 - 15 - 10 - 10
        
        guard let url = URL(string: "https://itutbox.s3.amazonaws.com/picture/production/2457A79A-46E3-4A76-8EB4-EE480CCB2A03.jpg") else { return }
        imageView_cover.sd_setImage(with: url)
    }
}
