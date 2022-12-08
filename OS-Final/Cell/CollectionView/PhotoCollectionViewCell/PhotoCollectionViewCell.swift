//
//  PhotoCollectionViewCell.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/12/6.
//

import UIKit
import SDWebImage

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView_photo: UIImageView!
    @IBOutlet var imageView_photo_height: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        componentsInit()
    }
    
    private func componentsInit() {
        guard let url = URL(string: "https://itutbox.s3.amazonaws.com/picture/production/2457A79A-46E3-4A76-8EB4-EE480CCB2A03.jpg") else { return }
        imageView_photo.sd_setImage(with: url)
        imageView_photo_height.constant = AppWidth / 3 - 15 - 5
    }
}
